module ApplicationHelper
  def randomized_background_image
    # TODO: Fetch this from a database
    images = ["20110620-PAUR-0006.jpg",
      "20131022-PAUR-Aerials-0033.jpg",
      "20140308-PAUR-OpenLabsAndDoors-0007.jpg",
      "20160926_COMM_historyclass09.jpg",
      "20150512-BMED.jpg"]
    "new-backgrounds/" + images[rand(images.size)]
  end
end
