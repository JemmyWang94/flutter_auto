# 通过蒲公英 apiv2.0 上传ipa, 并获取上传后的信息
# 蒲公英官方api文档: https://www.pgyer.com/doc/view/api#paramInfo
module Fastlane
  module Actions
    module SharedValues
      FX_UPLOAD_PGY = :FX_UPLOAD_PGY
    end

    class FxUploadPgyAction < Action
      def self.run(params)
        print "Hello, " 
        url = 'https://www.pgyer.com/apiv2/app/upload' # 2.0版本api

        api_key = params[:api_key] # (必填) API Key, 蒲公英用户设置相关页面查看
        file    = params[:file] # (必填) 需要上传的ipa或者apk文件路径
        desc    = params[:desc] # (选填) 版本更新描述，请传空字符串，或不传。

        if !File.exist?(file)
            UI.user_error!("❌❌❌ 需要上传的ipa文件不存在!!!")
        end
        UI.user_error!("❌❌❌ api_key 为空") if api_key.nil? || api_key.empty?

        file_name = File::basename(file)

        UI.message "👨‍🍳 准备上传ipa到蒲公英 待上传文件目录: #{file}"

        require 'net/https'

        url = URI(url)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        # 设置请求参数
        data = [
            ['_api_key', api_key],
            ['buildUpdateDescription', desc],
            ['file', File.open(file)]
        ]

        request = Net::HTTP::Post.new(url.path)
        request.set_form(data, 'multipart/form-data')

        response = http.request(request)

        data = JSON.parse(response.body)
        obj = data["data"]

        buildVersion = obj["buildVersion"] # 版本号
        buildVersionNo = obj["buildVersionNo"] # 构建版本号
        buildBuildVersion = obj["buildBuildVersion"] # 蒲公英构建版本号
        buildUpdateDescription = obj["buildUpdateDescription"] # 更新说明
        buildShortcutUrl = obj["buildShortcutUrl"] # 应用短链接, 需要凭借蒲公英域名
        buildQRCodeURL = obj["buildQRCodeURL"] # 应用二维码地址
        buildName = obj["buildName"] # 应用名称

        code = data["code"]
        message = data["message"]

        short_download_url = "https://www.pgyer.com/#{buildShortcutUrl}"

        result = {'buildVersion': buildVersion, 
                  'buildVersionNo': buildVersionNo, 
                  'buildBuildVersion': buildBuildVersion,
                  'buildUpdateDescription': buildUpdateDescription, 
                  'buildShortcutUrl': short_download_url, 
                  'buildQRCodeURL': buildQRCodeURL,
                  'buildName': buildName}

        if code === 0
          UI.success("🎉🎉🎉 ipa上传蒲公英成功 下载链接: #{short_download_url} 二维码地址: #{buildQRCodeURL}")
        else
          UI.user_error!("[发抖] ipa上传蒲公英失败: #{code} #{message}")
        end

        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "上传ipa到蒲公英"
      end

      def self.details
        "上传ipa到蒲公英"
      end

      def self.available_options
        # 函数参数声明
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_FILE",
                                       description: "待上传ipa路径",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_API_KEY",
                                       description: "apiKey 获取见 https://www.pgyer.com/doc/view/api#paramInfo",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :desc,
                                       env_name: "FL_DESC", # The name of the environment variable
                                       description: "版本更新描述，请传空字符串，或不传", # a short description of this parameter
                                       default_value: "")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['FX_UPLOAD_PGY', 'A description of what this value contains']
        ]
      end

      def self.return_value
        ["返回上传后的相关数据"]
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
