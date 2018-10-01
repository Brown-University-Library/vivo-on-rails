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

  def manager_url()
    ENV['MANAGER_URL']
  end

  def contact_us_url()
    url = "https://docs.google.com/forms/d/e/1FAIpQLSe9_8wO8f6Vd0E0N_ZVXiBN2YSO7NmWvP-utEGiQLJXz3nkJA/viewform?usp=pp_url&entry.1922592043&entry.911094868&entry.1400327620&entry.197578216&entry.19651479={LINK}"
    if defined?(request) && request != nil
      link = CGI.escape(request.url)
    else
      link = ""
    end
    url.gsub("{LINK}", link)
  end
end
