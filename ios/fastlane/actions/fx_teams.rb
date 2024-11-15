module Fastlane
  module Actions
    module SharedValues
      FX_TEAMS_CUSTOM_VALUE = :FX_TEAMS_CUSTOM_VALUE
    end

    class FxTeamsAction < Action
      def self.run(params)
        msgtype = params[:msgtype] # 消息类型，在Teams中可以简单分为文本等类型，这里暂以text示例
        content = params[:content] # 消息内容，格式按Teams要求调整
        url = params[:webhook] # Teams频道的webhook

        UI.message ">>> 即将发送Teams频道消息 消息类型: #{msgtype} 传入的参数: #{content}"

        require 'net/http'
        require 'json'

        # post 请求
        requesturl = URI("#{url}")
        http = Net::HTTP.new(requesturl.host, requesturl.port)
        header = {'content-type': 'application/json'}

        # 构建符合Teams要求的消息体格式
        # 以简单的文本消息为例，Teams中消息体格式大致如下（可按需扩展更多类型）
        message_payload = {
            "type": "message",
            "attachments": [
                {
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "version": "1.3",
                        "type": "AdaptiveCard",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": content,
                                "size": "Medium",
                                "weight": "Bolder",
                                "wrap": true
                            }
                        ],
                        "actions": [
                            {
                                "type": "Action.OpenUrl",
                                "title": "查看详情",
                                "url": "https://www.pgyer.com/odwqzT07"
                            }
                        ]
                    }
                }
            ]
        }.to_json

        # POST请求 下面两个配置必须要有（根据实际环境可能需要调整验证相关设置）
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        response = http.post(requesturl, message_payload, header)
        result = JSON.parse(response.body)

        UI.message ">>> 返回的发送结果: #{result}"
        # 在Teams中，没有errcode字段来判断，一般根据响应状态码等判断是否发送成功，这里示例简单判断状态码是否为200
        if response.is_a?(Net::HTTPSuccess)
            UI.message "消息成功发送到Microsoft Teams！"
        elsif response.is_a?(Net::HTTPBadRequest)
            UI.message "请求格式错误：#{response.body}"
        elsif response.is_a?(Net::HTTPUnauthorized)
            UI.message "未授权访问，可能Webhook地址或权限有问题：#{response.body}"
        elsif response.is_a?(Net::HTTPForbidden)
            UI.message "禁止访问，检查相关权限设置：#{response.body}"
        elsif response.is_a?(Net::HTTPNotFound)
            UI.message "Webhook地址未找到，确认地址是否正确：#{response.body}"
        else
            UI.message "发送消息到Microsoft Teams出现未知错误，状态码：#{response.code}，错误信息：#{response.body}"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "推送消息到Microsoft Teams频道"
      end

      def self.details
        "发送消息到指定的Microsoft Teams频道，实现通知功能"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :msgtype,
                                       env_name: "FL_TEAMS_MSGTYPE", # The name of the环境变量
                                       description: "发送的消息类型，默认为text类型",
                                       default_value: "text"),
          FastlaneCore::ConfigItem.new(key: :content,
                                       env_name: "FL_TEAMS_CONTENT",
                                       description: "消息的内容",
                                       is_string: true, # 这里简单假设内容是字符串类型，可按需调整
                                       default_value: "测试内容"),
          FastlaneCore::ConfigItem.new(key: :webhook,
                                       env_name: "FL_TEAMS_WEBHOOK", # The name of the环境变量
                                       description: "Teams webhook，默认为测试频道的机器人webhook",
                                       default_value: "")
        ]
      end

      def self.output
        [
          ['FX_TEAMS_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # 如果方法提供返回值，可以在此描述它的作用
      end

      def self.authors
        ["Jemmy.Wang"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end