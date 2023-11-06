#!/bin/bash
export UUID=${UUID:-'63d1e0c5-84f0-46f5-9a41-803b18ba4436'}
export NEZHA_SERVER=${NEZHA_SERVER:-'nz.f4i.cn'}
export NEZHA_PORT=${NEZHA_PORT:-'5555'}
export NEZHA_KEY=${NEZHA_KEY:-'C6jQbANlGLEFIoyr7X'}
export NEZHA_TLS=${NEZHA_TLS:-''}
export ARGO_DOMAIN=${ARGO_DOMAIN:-''}
export ARGO_TOK=${ARGO_TOK:-''}
export CFIP=${CFIP:-'skk.moe'}
export NAME=${NAME:-'Sacling'}

cleanup_oldfiles() {
  rm -rf boot.log list.txt sub.txt config.json
}
cleanup_oldfiles
sleep 2

#生成xr-ay配置文件
generate_config() {
  cat > config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
            "port":8080,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":3001
                    },
                    {
                        "path":"/vless",
                        "dest":3002
                    },
                    {
                        "path":"/vmess",
                        "dest":3003
                    },
                    {
                        "path":"/trojan",
                        "dest":3004
                    },
                    {
                        "path":"/shadowsocks",
                        "dest":3005
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3001,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/vless"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3003,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/vmess"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3004,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/trojan"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3005,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/shadowsocks"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds":[
        {
            "protocol":"freedom"
        },
        {
            "tag":"WARP",
            "protocol":"wireguard",
            "settings":{
                "secretKey":"YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address":[
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers":[
                    {
                        "publicKey":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs":[
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint":"162.159.193.10:2408"
                    }
                ],
                "reserved":[78, 135, 76],
                "mtu":1280
            }
        }
    ],
    "routing":{
        "domainStrategy":"AsIs",
        "rules":[
            {
                "type":"field",
                "domain":[
                    "domain:openai.com",
                    "domain:ai.com"
                ],
                "outboundTag":"WARP"
            }
        ]
    }
}
EOF
}
generate_config
sleep 3

# 运行ne-zha
run_swith() {
  chmod 755 swith
  [ "${NEZHA_TLS}" = "1" ] && NEZHA_TLS='--tls'
  nohup ./swith -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} >/dev/null 2>&1 &
}
run_swith
sleep 2

# 运行xr-ay
run_web() {
  chmod 755 web
  nohup ./web -c ./config.json >/dev/null 2>&1 &
}
run_web
sleep 2

# 运行argo
run_argo() {
chmod 755 server
if [[ -n "${ARGO_TOK}" ]]; then
ARGO_TOK=$(echo ${ARGO_TOK} | sed 's@cloudflared.exe service install ey@ey@g')
    if [[ "${ARGO_TOK}" =~ TunnelSecret ]]; then
      echo "${ARGO_TOK}" | sed 's@{@{"@g;s@[,:]@"\0"@g;s@}@"}@g' > tunnel.json
      cat > tunnel.yml << EOF
tunnel: $(sed "s@.*TunnelID:\(.*\)}@\1@g" <<< "${ARGO_TOK}")
credentials-file: tunnel.json
protocol: http2

ingress:
  - hostname: $ARGO_DOMAIN
    service: http://localhost:8080
EOF
      cat >> tunnel.yml << EOF
  - service: http_status:404
EOF
      nohup ./server tunnel --edge-ip-version auto --config tunnel.yml run >/dev/null 2>&1 &
    elif [[ ${ARGO_TOK} =~ ^[A-Z0-9a-z=]{120,250}$ ]]; then
      nohup ./server tunnel --edge-ip-version auto --protocol http2 run --token ${ARGO_TOK} >/dev/null 2>&1 &
    fi
else
 nohup ./server tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile boot.log --loglevel info --url http://localhost:8080 2>/dev/null 2>&1 &
 sleep 5

 export ARGO_DOMAIN=$(cat boot.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
 sleep 2
fi

#生成list和sub
generate_links() {
  isp=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18"-"$30}' | sed -e 's/ /_/g')
  sleep 2
    cat > list.txt <<EOF
vless://${UUID}@${CFIP}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2Fvless?ed=2048#${NAME}-${isp}
EOF
    cat list.txt
base64 -w0 list.txt > sub.txt 
  echo -e "files saved successfully "
}
generate_links
}
run_argo

cleanup_files() {
  sleep 10  
  rm -rf boot.log config.json tunnel.json tunnel.yml
}
cleanup_files

tail -f /dev/null