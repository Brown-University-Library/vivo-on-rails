module ApplicationHelper
  def randomized_background_image
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
    url = "https://docs.google.com/forms/d/e/1FAIpQLSfK1UdN-DfWid2UbboAXc3Pj_rgZZqI0E7dHI58EOdTlYLrrQ/viewform?usp=pp_url&entry.1611024492={LINK}"
    if defined?(request) && request != nil
      link = CGI.escape(request.url)
    else
      link = ""
    end
    url.gsub("{LINK}", link)
  end
end
