module ApplicationHelper

def randomized_background_image
  images = ["assets/new-backgrounds/20110620-PAUR-0006.jpg", "assets/new-backgrounds/20131022-PAUR-Aerials-0033.jpg", "assets/new-backgrounds/20140308-PAUR-OpenLabsAndDoors-0007.jpg"]
  images[rand(images.size)]
end

end
