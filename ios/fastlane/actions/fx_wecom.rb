# 发送消息到企业微信
module Fastlane
  module Actions
    module SharedValues
      FX_WECOM_CUSTOM_VALUE = :FX_WECOM_CUSTOM_VALUE
    end

    class FxWecomAction < Action
      def self.run(params)
        msgtype = params[:msgtype] # 消息类型
        dict    = params[:content] # 消息内容, 格式见企业微信机器人发送消息文档
        url     = params[:webhook] # 企业微信群的 webhook

        UI.message ">>> 即将发送企业微信群消息 消息类型: #{msgtype} 传入的参数: #{dict}"

        require 'net/http'
        require 'json'

        # post 请求
        requesturl = URI("#{url}")
        http   = Net::HTTP.new(requesturl.host, requesturl.port)
        header = {'content-type':'application/json'}
        params = {'msgtype':"#{msgtype}", "#{msgtype}": dict}.to_json

        # POST请求 下面两个配置必须要有
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        response = http.post(requesturl, params, header)
        result   = JSON.parse(response.body)
        errcode  = result["errcode"]

        UI.message("👉👉👉 执行机器人: #{url}")
        if errcode == 0
          UI.success("🎉🎉🎉 企微发送成功: #{response.body}")
        else
          UI.user_error!("[发抖] 企微发送失败: #{response.body}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "推送消息到企业微信群"
      end

      def self.details
        "发送消息到指定的企业微信群, 实现通知功能"
      end

      def self.available_options
        # 函数参数声明
        [
          FastlaneCore::ConfigItem.new(key: :msgtype,
                                       env_name: "FL_WECHAT_MSGTYPE", # The name of the environment variable
                                       description: "发送的消息类型, 默认为 text 类型", # a short description of this parameter
                                       default_value: "text"),
          FastlaneCore::ConfigItem.new(key: :content,
                                       env_name: "FL_WECHAT_CONTENT",
                                       description: "消息的内容",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: {"content":"测试内容"}), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :webhook,
                                       env_name: "FL_WECHAT_WEBHOOK", # The name of the environment variable
                                       description: "WeCom webhook, 默认为测试群的机器人webhook", # a short description of this parameter
                                       default_value: "")# https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=60790c71-4c86-4a11-9f92-675888b4c7e2
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['FX_WECOM_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        ["Jemmy.Wang"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
