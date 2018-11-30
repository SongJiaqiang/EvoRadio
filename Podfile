source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'EvoRadio' do
    
  # UI Debug
  pod 'FLEX', '~> 2.4', :configurations => ['Debug'], :inhibit_warnings => true
  # 自动布局
  pod 'SnapKit'
  # 列表刷新
  pod 'MJRefresh'
  # 提示蒙版
  pod 'MBProgressHUD'
  # 动画特效
  pod 'pop'
  # 旋转木马特效
  pod 'iCarousel'

  # 网络请求
  pod 'Alamofire', '~> 4.7'
  # 图片加载
  pod 'Kingfisher'
  # crash监控
  pod 'Fabric'
  pod 'Crashlytics'
  # 对象远程存储
  pod 'Firebase/Core'
  
  # 对象本地持久化
  pod 'ObjectMapper', '~> 3.4'
  
  # 音频播放
  pod 'StreamingKit'

  target 'EvoRadioTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
