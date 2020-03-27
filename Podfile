source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/SongJiaqiang/Specs.git'

use_frameworks!
inhibit_all_warnings!

def common_pods
  # 网络请求
  pod 'Alamofire',      '4.8.0'
  # 图片加载
  pod 'Kingfisher',     '4.10.1'
  # 对象本地持久化
  pod 'ObjectMapper',   '3.4.1'
  # 音频播放
  pod 'StreamingKit',   '0.1.30'
  # SQLite数据库
  pod 'SQLite.swift'
  # 音乐库
  pod 'Lava'
end

target 'EvoRadio' do
  platform :ios, '10.0'

  common_pods()
  
  # UI调试工具
  pod 'FLEX',           '2.4.0', :configurations => ['Debug'], :inhibit_warnings => true
  # 自动布局
  pod 'SnapKit',        '4.2.0'
  pod 'PureLayout',     '~> 3.1.0'
  # 列表刷新
  pod 'MJRefresh',      '3.1.15.7'
  # 提示蒙版
  pod 'MBProgressHUD',  '1.1.0'
  # 动画特效
  pod 'pop',            '1.0.12'
  # 旋转木马特效
  pod 'iCarousel',      '1.8.3'
  # 基础类扩展
  pod 'JQFisher',       '0.1.2'

  target 'EvoRadioTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'EvoRadioMac' do
  platform :osx, '10.12'
  
  common_pods()
  
  target 'EvoRadioMacTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
