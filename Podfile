platform :ios, '10.0'

def shared_pods
  pod 'RxSwift'
  pod 'SwiftLint'
  pod 'RxCocoa'
end

target 'Nimble' do
  use_frameworks!
  shared_pods
end

target 'NimbleTests' do
  inherit! :search_paths
  use_frameworks!
  shared_pods
  pod 'RxTest'
end
