

Pod::Spec.new do |spec|
# 库名称
  spec.name         = "CZFilterMenu"

# 对应Github中的tag
  spec.version      = "0.0.4"

# 是否开启ARC
spec.requires_arc = true

# 这里只支持iO,且指定了最低版本(可省略)
  spec.platform     = :ios, "10.0"
# 支持多个平台使用时
# s.ios.deployment_target = "x"
# s.osx.deployment_target = "x"
# s.watchos.deployment_target = "x"
# s.tvos.deployment_target = "x"

# 库的简介
  spec.summary      = "模仿贝壳找房下拉菜单"
# 库的具体描述,可以不写,但写了就一定要比简介长
  spec.description  = <<-DESC
                        模仿贝壳找房下拉菜单,支持一、二、三级列表,自定义输入等
                   DESC

# 库的介绍页面,一般就是github中的项目地址
  spec.homepage     = "https://github.com/JQZhangC/CZFilterMenuView"

 # 开源协议,采用MIT即可 
  spec.license      = { :type => "MIT", :file => "LICENSE" }

# 作者信息
  spec.author             = { "CZ" => "cooper_jx@126.com" }

# 库的git地址,需要的是git地址不要和介绍页面搞混
  spec.source       = { :git => "https://github.com/JQZhangC/CZFilterMenuView.git", :tag => "#{spec.version}" }


# 当前目录是podspec文件所在的目录
# source_files(包括次级文件夹)使用的都是相对路径,这里就是CZFilterMenu.podspec所在的目录
# 指明git项目哪些文件会被cocoapods引用
  spec.source_files  = "CZFilterMenu", "CZFilterMenuView/CZFilterMenu/*.{h,m}"

  # 次级文件夹,如果有些问下是在文件夹中的话,一定这么写
  # Helper为文件夹名,ss可以看错是别名(指代使用),source_files指明次一级文件的路径
  # 必须要使用end结束
  spec.subspec 'Helper' do |ss|
    ss.source_files = 'CZFilterMenuView/CZFilterMenu/Helper/*.{h,m}'
  end
    
  spec.subspec 'View' do |ss|
    ss.source_files = 'CZFilterMenuView/CZFilterMenu/View/*.{h,m}'
  end

# xib文件和图片文件
spec.resource_bundles = {
  'CZFilterMenuResource' => ['CZFilterMenuView/CZFilterMenu/View/*.xib','CZFilterMenuView/Assets/*.png']
  }

# 忽略文件,目标路径(相对路径)下的文件不进行下载
#spec.exclude_files = ""

# 库中用到的框架或系统库（没用到可以没有）
spec.ios.frameworks = 'Foundation', 'UIKit'
# spec.framework  = ""
# spec.frameworks = "", ""
# spec.libraries = "",""
# 使用到的第三方库
# spec.vendored_frameworks = ''
# spec.vendored_libraries = ''

# 如果你的库依赖其他的 Podspecs，可以添加这些依赖项，例如
# spec.dependency 'AFNetworking', '~> 3.2.1'

end
