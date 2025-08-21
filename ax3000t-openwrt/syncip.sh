#!/bin/sh

# Cloudflare API 更新脚本 - 检测IPv6地址变化并更新多个DNS记录
# 使用前请配置以下参数
API_KEY=""
ZONE_ID=""
EMAIL=""
IP_FILE="/tmp/ipsync_ip"

# 配置多个主机名及其对应的DNS记录ID
# 格式: "主机名1:DNS记录ID1,主机名2:DNS记录ID2,主机名3:DNS记录ID3"
HOSTNAMES=""


# 获取当前IPv6地址
# get_current_ipv6() {
#     current_ipv6=$(ifconfig | grep -A2 'inet6 addr:' | grep -v 'inet6 fe80' | awk '/inet6/ {print $2}' | tail -1)
#     echo "$current_ipv6"
# }

get_current_ipv6() {
    # current_ipv6=$(ifconfig | grep 'Scope:Global' | grep 'inet6' | awk '{print $3}' | cut -d/ -f1 | tail -1)
    
    #current_ipv6=$(ifconfig | grep 'inet6' | grep 'global' | grep -v 'fe80' | grep -v 'fdd0' | awk '{print $2}')
    current_ipv6=$(ifconfig | grep 'inet6' | grep 'Global' | grep -v 'fe80' | grep -v 'fdd0' | awk '{print $3}' | cut -d/ -f1 | tail -1)
    echo "$current_ipv6"
}

# 检查文件是否存在，不存在则创建
check_ip_file() {
    if [ ! -f "$IP_FILE" ]; then
        touch "$IP_FILE"
        echo "创建IP文件: $IP_FILE"
    fi
}

# 读取存储的IPv6地址
read_stored_ipv6() {
    if [ -f "$IP_FILE" ]; then
        stored_ipv6=$(cat "$IP_FILE")
        echo "$stored_ipv6"
    else
        echo ""
    fi
}

# 更新Cloudflare DNS记录
update_cloudflare_dns() {
    local hostname=$1
    local record_id=$2
    local new_ip=$3
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "更新域名记录: $hostname (记录ID: $record_id)"
    
    # 构建API请求
    response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
         -H "X-Auth-Email: $EMAIL" \
         -H "X-Auth-Key: $API_KEY" \
         -H "Content-Type: application/json" \
         --data '{"comment": "Updated at '"$time"'","type":"AAAA","name":"'"$hostname"'","content":"'"$new_ip"'","ttl":120,"proxied":false}')
    
    # 检查API响应
    success=$(echo "$response" | grep -o '"success":true' | head -1)
    if [ "$success" = "\"success\":true" ]; then
        echo "✅ $hostname 更新成功"
    else
        echo "❌ $hostname 更新失败"
        echo "API响应: $response"
        return 1
    fi
}

# 主函数
main() {
    check_ip_file
    current_ip=$(get_current_ipv6)
    stored_ip=$(read_stored_ipv6)
    
    echo "当前IP: $current_ip"
    echo "存储IP: $stored_ip"
    
    if [ "$current_ip" != "$stored_ip" ]; then
        echo "检测到IP变更: $current_ip"
        update_result=0
        
        # 使用逗号分隔的HOSTNAMES变量替代数组
        IFS=','
        for host_entry in $HOSTNAMES; do
            IFS=':'
            set -- $host_entry
            hostname=$1
            record_id=$2
            
            if ! update_cloudflare_dns "$hostname" "$record_id" "$current_ip"; then
                update_result=1
            fi
        done
        
        # 如果所有更新都成功，才更新存储的IP
        if [ $update_result -eq 0 ]; then
            echo "$current_ip" > "$IP_FILE"
            echo "新IP已保存到 $IP_FILE"
        else
            echo "⚠️ 部分更新失败，保留旧IP记录"
            exit 1
        fi
    else
        echo "IP未变更，无需更新"
    fi
}

main    