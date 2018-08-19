# Fastlane tool scripts
#
#

default_platform(:ios)

platform :ios do

  desc "Description of what the lane does"
  lane :test do
    sh """ echo HELLO FASTLANE """
  end


  desc "Update carthage frameworks"
  lane :carthage do
    sh """ carthage update --platform ios """
  end

end
