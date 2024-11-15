# 配置项目的build settings
module Fastlane
  module Actions
    module SharedValues
      FX_SET_BUILD_SETTINGS = :FX_SET_BUILD_SETTINGS
    end

    class FxSetBuildSettingsAction < Action
      def self.run(params)

        project_name   = params[:project_name] # (必填) 项目名称
        xcodeproj_path = params[:xcodeproj_path] # Xcodeproj文件路径
        input_config   = params[:config] # 待修改配置项的环境, 不传默认修改全部环境
        settings_key   = params[:settings_key] # 待修改项的名称
        settings_value = params[:settings_value] # 待修改项的值

        UI.user_error!("❌❌❌ project_name 为空") if project_name.nil? || project_name.empty?
        UI.user_error!("❌❌❌ settings_key 为空") if settings_key.nil? || settings_key.empty?
        UI.message("👉👉👉 config 为空, 默认修改全部环境的配置项") if input_config.nil? || input_config.empty?

        if xcodeproj_path.nil? || xcodeproj_path.empty?
          # 未传入路径, 默认为传入项目名对应路径
          xcodeproj_path = "./#{project_name}.xcodeproj"
        end

        # ruby 使用这个库获取 build setting 相关配置参数
        require 'xcodeproj'

        UI.message("👨‍🍳 开始修改 #{project_name} 的 build settings")

        project = Xcodeproj::Project.open(xcodeproj_path)

        selected_target = project.targets[0]
        # 获取 project_name 对应的 target
        project.targets.each do |target|
          if target.name == project_name
              selected_target = target
          end
        end

        selected_target.build_configurations.each do |config|

          # # 遍历 build settings 的配置
          # build_settings.each do |key, value|
          #     puts "获取的settings配置信息: #{key} : #{value}"
          # end FLUTTER_BUILD_MODE

          if input_config.nil? | input_config.empty?
            # 未传入config, 默认修改所有环境的配置项
            build_settings = config.build_settings
            UI.message("👉👉👉 修改 #{config.name} 下的 settings")
            UI.message("👉👉👉 修改配置前: #{settings_key} : #{build_settings[settings_key]}")
            build_settings[settings_key] = settings_value
            UI.message("👉👉👉 修改配置后: #{settings_key} : #{build_settings[settings_key]}")
          else 
            # 传入config, 修改对应环境的配置项
            if config.name == input_config
              build_settings = config.build_settings
              UI.message("👉👉👉 修改 #{config.name} 下的 settings")
              UI.message("👉👉👉 修改配置前: #{settings_key} : #{build_settings[settings_key]}")
              build_settings[settings_key] = settings_value
              UI.message("👉👉👉 修改配置后: #{settings_key} : #{build_settings[settings_key]}")
            end
          end

        end

        # 保存以上修改信息
        project.save

        UI.success("🎉🎉🎉 完成修改 #{project_name} 的 build settings")

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "修改项目build settings"
      end

      def self.details
        "修改项目build settings"
      end

      def self.available_options
        # 函数参数声明
        [
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_PROJECT_NAME",
                                       description: "项目名称",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :xcodeproj_path,
                                       env_name: "FL_XCODEPROJ_PATH",
                                       description: "Xcodeproj文件路径",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :config,
                                       env_name: "FL_CONFIG", # The name of the environment variable
                                       description: "build 环境, 不传默认修改全部环境的settings", # a short description of this parameter
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :settings_key,
                                       env_name: "FL_SETTINGS_KEY", # The name of the environment variable
                                       description: "需要配置的 settings选项 名称", # a short description of this parameter
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :settings_value,
                                       env_name: "FL_SETTINGS_VALUE", # The name of the environment variable
                                       description: "需要配置的 settings选项 值", # a short description of this parameter
                                       default_value: ""),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['FX_SET_BUILD_SETTINGS', 'A description of what this value contains']
        ]
      end

      def self.return_value
        ["暂无返回数据"]
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
