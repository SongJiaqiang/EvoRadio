source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/SongJiaqiang/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def common_pods
  # UI调试工具
  pod 'FLEX',           '2.4.0', :configurations => ['Debug'], :inhibit_warnings => true
  # 自动布局
  pod 'SnapKit',        '4.2.0'
  # 列表刷新
  pod 'MJRefresh',      '3.1.15.7'
  # 提示蒙版
  pod 'MBProgressHUD',  '1.1.0'
  # 动画特效
  pod 'pop',            '1.0.12'
  # 旋转木马特效
  pod 'iCarousel',      '1.8.3'
  # 网络请求
  pod 'Alamofire',      '4.8.0'
  # 图片加载
  pod 'Kingfisher',     '4.10.1'
  # 对象本地持久化
  pod 'ObjectMapper',   '3.4.1'
  # 音频播放
  pod 'StreamingKit',   '0.1.30'
  # 基础类扩展
  pod 'JQFisher',       '0.1.2'
end

target 'EvoRadio' do
  common_pods()

  target 'EvoRadioTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
