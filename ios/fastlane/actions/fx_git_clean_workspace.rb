# 清空本地工作区未保存的代码
module Fastlane
  module Actions
    module SharedValues
      FX_GIT_CLEAN_WORKSPACE = :FX_GIT_CLEAN_WORKSPACE
    end

    class FxGitCleanWorkspaceAction < Action
      def self.run(params)

        UI.message("git_clean_workspace 当前路径: #{Dir::pwd}")

        UI.message("👉👉👉 执行 git reset .")
        system("git reset .")
        
        UI.message("👉👉👉 执行 git checkout .")
        system("git checkout .")
        
        UI.message("👉👉👉 执行 git clean -f")
        system("git clean -f")
        
        UI.success("🎉🎉🎉 清空本地工作区未提交代码 执行完毕!")

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "清空本地工作区未保存的代码"
      end

      def self.details
        "清空本地工作区, 更新分支代码, 避免未提交的代码影响打包结果"
      end

      def self.available_options
        # 函数参数声明
        []
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['FX_GIT_CLEAN_WORKSPACE', 'A description of what this value contains']
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
