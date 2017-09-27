module ApplicationHelper
  def randomized_background_image
    # TODO: Fetch this from a database
    images = ["20110620-PAUR-0004.jpg",
      "20130419_WICLACS_0004.jpg",
      "20131022-PAUR-Aerials-0033.jpg",
      "20131118-PAUR-0005.jpg",
      "20140308-PAUR-OpenLabsAndDoors-0007.jpg",
      "20150422_MayaLinTEST-PAUR-0026.jpg",
      "20150512-BMED.jpg",
      "20160822_COMM_TessCasswell07.jpg"]
    "new-backgrounds/" + images[rand(images.size)]
  end

  def contact_us_url
    "https://docs.google.com/a/brown.edu/forms/d/1H_LzEHRzpxv3OY266RjSwpAMwVuTEUFyNEgMPcZ4NiA/viewform"
  end
end
