class BookCoversSampleData
  # We only use this data in development so that Crystal and Ben can get data
  # for the carousel without having to connect to the production MySQL database.
  def self.get_all()
    host_url = (ENV["HOST_URL"] || "") + "/display"
    covers = []

    cover = BookCoverModel.new()
    cover.author_first = "James"
    cover.author_last = "Allen"
    cover.author_id = "jpallen"
    cover.author_url = "#{host_url}/jpallen"
    cover.title = "Middle Egyptian Literature: Eight Literary Works of the Middle Kingdom"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Allen_MiddleEgyptianLiterature.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Peter"
    cover.author_last = "Andreas"
    cover.author_id = "pandreas"
    cover.author_url = "#{host_url}/pandreas"
    cover.title = "Rebel Mother: My Childhood Chasing the Revolution"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Andreas_RebelMother.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Richard"
    cover.author_last = "Arenberg"
    cover.author_id = "rarenber"
    cover.author_url = "#{host_url}/rarenber"
    cover.title = "Defending the Filibuster: The Soul of the Senate, Revised and Updated"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Arenberg_DefendingTheFilibuster.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Paul"
    cover.author_last = "Armstrong"
    cover.author_id = "pbarmstr"
    cover.author_url = "#{host_url}/pbarmstr"
    cover.title = "Norton Critical Edition of Joseph Conrad, Heart of Darkness, 5th ed"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Armstrong_HeartofDarkness.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Nomy"
    cover.author_last = "Arpaly"
    cover.author_id = "narpaly"
    cover.author_url = "#{host_url}/narpaly"
    cover.title = "In Praise of Desire by Nomy Arpaly"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/arpaly.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Ethan"
    cover.author_last = "Balk"
    cover.author_id = "ebalk"
    cover.author_url = "#{host_url}/ebalk"
    cover.title = "Benefits and Harms of Routine Preoperative Testing"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Balk_BenefitsAndHarms.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Omer"
    cover.author_last = "Bartov"
    cover.author_id = "obartov"
    cover.author_url = "#{host_url}/obartov"
    cover.title = "The Holocaust: Origins, Implementation, Aftermath, 2nd Edition"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Bartov_Holocaust.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Adia"
    cover.author_last = "Benton"
    cover.author_id = "abenton"
    cover.author_url = "#{host_url}/abenton"
    cover.title = "HIV Exceptionalism: Development through Disease in Sierra Leone"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/abenton.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Mutlu "
    cover.author_last = "Blasing"
    cover.author_id = "mblasing"
    cover.author_url = "#{host_url}/mblasing"
    cover.title = "Nazim Hikmet: The Life and Times of Turkey's World Poet"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/blasing.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Mark"
    cover.author_last = "Blyth"
    cover.author_id = "mblyth"
    cover.author_url = "#{host_url}/mblyth"
    cover.title = "Austerity: The History of a Dangerous Idea"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/blyth.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Elizabeth"
    cover.author_last = "Brainerd"
    cover.author_id = "ebrainer"
    cover.author_url = "#{host_url}/ebrainer"
    cover.title = "Great Transformations in Vertebrate Evolution"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Brainerd_GreatTransformations.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Lundy"
    cover.author_last = "Braun"
    cover.author_id = "lbraun"
    cover.author_url = "#{host_url}/lbraun"
    cover.title = "Breathing Race into the Machine"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/lbraun.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Stephen"
    cover.author_last = "Bush"
    cover.author_id = "sb5"
    cover.author_url = "#{host_url}/sb5"
    cover.title = "Visions of Religion: Experience, Meaning, and Power"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Bush_VisionsOfReligion.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Melani C."
    cover.author_last = "Cammett"
    cover.author_id = "mcammett"
    cover.author_url = "#{host_url}/mcammett"
    cover.title = "Compassionate Communalism, Welfare and Sectarianism in Lebanon"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/cammett.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Caroline "
    cover.author_last = "Castiglione"
    cover.author_id = "ccastigl"
    cover.author_url = "#{host_url}/ccastigl"
    cover.title = "Accounting for Affection: Mothering and Politics in Early Modern Rome"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Castiglione_AccountingForAffection.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Colin"
    cover.author_last = "Channer"
    cover.author_id = "cchanner"
    cover.author_url = "#{host_url}/cchanner"
    cover.title = "Providential"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Channer_Providential.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Ross"
    cover.author_last = "Cheit"
    cover.author_id = "rcheit"
    cover.author_url = "#{host_url}/rcheit"
    cover.title = "The Witch-Hunt Narrative: Politics, Psychology, and the Sexual Abuse of Children"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/cheit.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Tamara"
    cover.author_last = "Chin"
    cover.author_id = "tc69"
    cover.author_url = "#{host_url}/tc69"
    cover.title = "Savage Exchange: Han Imperialism, Chinese Literary Style, and the Economic Imagination"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Chin_SavageExchange.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "David"
    cover.author_last = "Christensen"
    cover.author_id = "dchriste"
    cover.author_url = "#{host_url}/dchriste"
    cover.title = "The Epistemology of Disagreement: New Essays"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Christensen_Epistemology.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Howard"
    cover.author_last = "Chudacoff"
    cover.author_id = "hchudaco"
    cover.author_url = "#{host_url}/hchudaco"
    cover.title = "Changing the Playbook: How Power, Profit, and Politics Transformed College Sports"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/hchudaco.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Wendy"
    cover.author_last = "Chun"
    cover.author_id = "wchun"
    cover.author_url = "#{host_url}/wchun"
    cover.title = "New Media, Old Media: A History and Theory Reader"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Chun_NewMedia.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Barry"
    cover.author_last = "Connors"
    cover.author_id = "bconnors"
    cover.author_url = "#{host_url}/bconnors"
    cover.title = "Neuroscience: Exploring the Brain, 4th ed. "
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Connors_Neuroscience.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Harold"
    cover.author_last = "Cook"
    cover.author_id = "hjcook"
    cover.author_url = "#{host_url}/hjcook"
    cover.title = "Ways of Making and Knowing: The Material Culture of Empirical Knowledge"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Cook_WaysOfMakingAndKnowing.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Robert"
    cover.author_last = "Coover"
    cover.author_id = "rcoover"
    cover.author_url = "#{host_url}/rcoover"
    cover.title = "Brunist Day of Wrath by Robert Coover"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/coover.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Eric"
    cover.author_last = "Darling"
    cover.author_id = "ed12"
    cover.author_url = "#{host_url}/ed12"
    cover.title = "Articular Cartilage, Second Edition"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Darling_ArticularCartilage.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Nicola"
    cover.author_last = "Denzey"
    cover.author_id = "ndenzey"
    cover.author_url = "#{host_url}/ndenzey"
    cover.title = "Cosmology and Fate in Gnosticism and the Graeco-Roman World: Under A Pitiless Sky"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Denzey_CosmologyAndFate.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Paja"
    cover.author_last = "Faudree"
    cover.author_id = "pfaudree"
    cover.author_url = "#{host_url}/pfaudree"
    cover.title = "Singing for the Dead: The Politics of Indigenous Revival in Mexico "
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/faudree.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Thalia"
    cover.author_last = "Field"
    cover.author_id = "tfield"
    cover.author_url = "#{host_url}/tfield"
    cover.title = "Experimental Animals: A Reality Fiction"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Field_ExperimentalAnimals.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Linford"
    cover.author_last = "Fisher"
    cover.author_id = "lf7"
    cover.author_url = "#{host_url}/lf7"
    cover.title = "Decoding Roger Williams: The Lost Essay of Rhode Island's Founding Father"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Fisher_DecodingRogerWilliams.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Caroline "
    cover.author_last = "Frank"
    cover.author_id = "cfrank"
    cover.author_url = "#{host_url}/cfrank"
    cover.title = "Global Trade and Visual Arts in Federal New England "
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Frank_GlobalTrade.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Hannah"
    cover.author_last = "Freed-Thall"
    cover.author_id = "hfreedth"
    cover.author_url = "#{host_url}/hfreedth"
    cover.title = "Spoiled Distinctions: Aesthetics and the Ordinary in French Modernism"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Freed-Thall_SpoiledDistinctions.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Forrest "
    cover.author_last = "Gander"
    cover.author_id = "fgander"
    cover.author_url = "#{host_url}/fgander"
    cover.title = "The Trace"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Gander_trace.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Leela"
    cover.author_last = "Gandhi"
    cover.author_id = "lgandhi"
    cover.author_url = "#{host_url}/lgandhi"
    cover.title = "The Common Cause: Postcolonial Ethics and the Practice of Democracy, 1900-1955 "
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Gandhi_TheCommonCause.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Eric"
    cover.author_last = "Gartman"
    cover.author_id = "egartman"
    cover.author_url = "#{host_url}/egartman"
    cover.title = "Ultrasound in the Intensive Care Unit"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Gartman_UltrasoundInTheIntensiveCareUnit.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Victor"
    cover.author_last = "Golstein"
    cover.author_id = "vgolstei"
    cover.author_url = "#{host_url}/vgolstei"
    cover.title = "Svetlana Aleksijevitj – Sovjetintelligentians Röst (The Voice of Soviet Intelligentsia)"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Golstein_Svetlana.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Spencer"
    cover.author_last = "Golub"
    cover.author_id = "sgolub"
    cover.author_url = "#{host_url}/sgolub"
    cover.title = "Incapacity: Wittgenstein, Anxiety, and Performance Behavior "
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/sgolub.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Philip"
    cover.author_last = "Gould"
    cover.author_id = "pgould"
    cover.author_url = "#{host_url}/pgould"
    cover.title = "Writing the Rebellion: Loyalists and the Literature of Politics in British America"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/gould.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "James"
    cover.author_last = "Green"
    cover.author_id = "jngreen"
    cover.author_url = "#{host_url}/jngreen"
    cover.title = "Ditadura e homossexualidades : repressão, resistência e a busca da verdade"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Green_Ditadura.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Jo"
    cover.author_last = "Guldi"
    cover.author_id = "eguldi"
    cover.author_url = "#{host_url}/eguldi"
    cover.title = "The History Manifesto"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Guldi_TheHistoryManifesto.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Matthew"
    cover.author_last = "Guterl"
    cover.author_id = "mguterl"
    cover.author_url = "#{host_url}/mguterl"
    cover.title = "Hotel Life: The Story of a Place Where Anything Can Happen"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Guterl_HotelLife.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Matthew"
    cover.author_last = "Gutmann"
    cover.author_id = "mgutmann"
    cover.author_url = "#{host_url}/mgutmann"
    cover.title = "Global Latin America: Into the Twenty-First Century"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Gutmann_GlobalLatinAmerica.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Françoise"
    cover.author_last = "Hamlin"
    cover.author_id = "fhamlin"
    cover.author_url = "#{host_url}/fhamlin"
    cover.title = "These Truly Are The Brave: An Anthology of African American Writings on War and Citizenship"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Hamlin_TheseTrulyAreTheBrave.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Johanna"
    cover.author_last = "Hanink"
    cover.author_id = "jhanink"
    cover.author_url = "#{host_url}/jhanink"
    cover.title = "The Classical Debt: Greek Antiquity in an Era of Austerity"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Hanink_ClassicalDebt.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Ömür "
    cover.author_last = "Harmanşah"
    cover.author_id = "oharmans"
    cover.author_url = "#{host_url}/oharmans"
    cover.title = "Place, Memory, and Healing: An Archaeology of Anatolian Rock Monuments "
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Harmansah_PlaceMemoryAndHealing.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Tim"
    cover.author_last = "Harris"
    cover.author_id = "tgharris"
    cover.author_url = "#{host_url}/tgharris"
    cover.title = "Rebellion: Britain's First Stuart Kings, 1567-1642"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/harris.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Kenneth"
    cover.author_last = "Haynes"
    cover.author_id = "khaynes"
    cover.author_url = "#{host_url}/khaynes"
    cover.title = "Broken Hierarchies: Collected Poems 1952-2012"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/haynes.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Stephen"
    cover.author_last = "Houston"
    cover.author_id = "shouston"
    cover.author_url = "#{host_url}/shouston"
    cover.title = "The Life Within: Classic Maya and the Matter of Permanence"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/houston.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = " Catherine "
    cover.author_last = "Imbriglio"
    cover.author_id = "cimbrigl"
    cover.author_url = "#{host_url}/cimbrigl"
    cover.title = "Intimacy"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/imbriglio.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Donald"
    cover.author_last = "Jackson"
    cover.author_id = "dcjackso"
    cover.author_url = "#{host_url}/dcjackso"
    cover.title = "Celebrating Life: An Appreciation of Animals in Verse and Prose "
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Jackson_Celebrating.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Nancy"
    cover.author_last = "Jacobs"
    cover.author_id = "njacobs"
    cover.author_url = "#{host_url}/njacobs"
    cover.title = "Birders of Africa: History of a Network "
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Jacobs_BirdersOfAfrica.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "David"
    cover.author_last = "Kertzer"
    cover.author_id = "dkertzer"
    cover.author_url = "#{host_url}/dkertzer"
    cover.title = "The Pope and Mussolini"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/kertzer.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Jacques"
    cover.author_last = "Khalip"
    cover.author_id = "jkhalip"
    cover.author_url = "#{host_url}/jkhalip"
    cover.title = "Constellations of a Contemporary Romanticism"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Khalip_Constellations.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Daniel"
    cover.author_last = "Kim"
    cover.author_id = "dakim"
    cover.author_url = "#{host_url}/dakim"
    cover.title = "The Cambridge Companion to Asian American Literature"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Kim_Cambridge.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Thomas"
    cover.author_last = "Kniesche"
    cover.author_id = "tkniesch"
    cover.author_url = "#{host_url}/tkniesch"
    cover.title = "Einführung in den Kriminalroman"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Kniesche_Einfuhrung.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Peter"
    cover.author_last = "Kramer"
    cover.author_id = "pkramerm"
    cover.author_url = "#{host_url}/pkramerm"
    cover.title = "Ordinarily Well: The Case for Antidepressants"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Kramer_OrdinarilyWell.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "George"
    cover.author_last = "Kroumpouzos"
    cover.author_id = "gkroumpo"
    cover.author_url = "#{host_url}/gkroumpo"
    cover.title = "Text Atlas of Obstetric Dermatology"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Kroumpouzos_TextAtlasOfObstetricDermatology.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "James"
    cover.author_last = "Kuzner"
    cover.author_id = "jkuzner"
    cover.author_url = "#{host_url}/jkuzner"
    cover.title = "Shakespeare as a Way of Life: Skeptical Practice and the Politics of Weakness"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Kuzner_ShakespeareAsAWayOfLife.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Jessaca "
    cover.author_last = "Leinaweaver"
    cover.author_id = "jleinawe"
    cover.author_url = "#{host_url}/jleinawe"
    cover.title = "Adoptive Migration: Raising Latinos in Spain"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/leinaweaver.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Philip"
    cover.author_last = "Lieberman"
    cover.author_id = "plieberm"
    cover.author_url = "#{host_url}/plieberm"
    cover.title = "The Unpredictable Species: What Makes Humans Unique "
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/plieberm.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Eng-Beng"
    cover.author_last = "Lim"
    cover.author_id = "el46"
    cover.author_url = "#{host_url}/el46"
    cover.title = "Brown Boys and Rice Queens: Spellbinding Performance in the Asias "
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/lim.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Evelyn"
    cover.author_last = "Lincoln"
    cover.author_id = "elincoln"
    cover.author_url = "#{host_url}/elincoln"
    cover.title = "Brilliant Discourse: Pictures and Readers in Early Modern Rome"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/lincoln.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Steven"
    cover.author_last = "Lubar"
    cover.author_id = "slubar"
    cover.author_url = "#{host_url}/slubar"
    cover.title = "Inside the Lost Museum: Curating, Past and Present"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Lubar_LostMuseum.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Catherine"
    cover.author_last = "Lutz"
    cover.author_id = "clutz"
    cover.author_url = "#{host_url}/clutz"
    cover.title = "Schooled: Ordinary, Extraordinary Teaching in an Age of Change"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/clutz.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Maud"
    cover.author_last = "Mandel"
    cover.author_id = "mmandel"
    cover.author_url = "#{host_url}/mmandel"
    cover.title = "Muslims and Jews in France "
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/mandel.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Courtney"
    cover.author_last = "Martin"
    cover.author_id = "cm40"
    cover.author_url = "#{host_url}/cm40"
    cover.title = "Lawrence Alloway: Critic and Curator"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Martin_LawrenceAlloway.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Felipe"
    cover.author_last = "Martinez-Pinzon"
    cover.author_id = "fmartin1"
    cover.author_url = "#{host_url}/fmartin1"
    cover.title = "Una cultura de invernadero: trópico y civilización en Colombia (1808-1928)"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Martinez_Pinzon_UnaCultura.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Katherine"
    cover.author_last = "Mason"
    cover.author_id = "kam6"
    cover.author_url = "#{host_url}/kam6"
    cover.title = "Infectious Change: Reinventing Chinese Public Health after an Epidemic"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Mason_Infectious.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Kevin"
    cover.author_last = "McLaughlin"
    cover.author_id = "kmclaugh"
    cover.author_url = "#{host_url}/kmclaugh"
    cover.title = "Poetic Force: Poetry after Kant"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/McLaughlin_PoeticForce.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "RIchard"
    cover.author_last = "Meckel"
    cover.author_id = "rmeckel"
    cover.author_url = "#{host_url}/rmeckel"
    cover.title = "Save the Babies: American Public Health Reform and the Prevention of Infant Mortality, 1850-1929"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Meckel_SaveTheBabies.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Brian"
    cover.author_last = "Meeks"
    cover.author_id = "bmeeks"
    cover.author_url = "#{host_url}/bmeeks"
    cover.title = "Freedom, Power and Sovereignty: The Thought of Gordon K. Lewis "
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Meeks_Freedom.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Christine"
    cover.author_last = "Montross"
    cover.author_id = "cmontros"
    cover.author_url = "#{host_url}/cmontros"
    cover.title = "Falling Into the Fire: A Psychiatrist's Encounters with the Mind in Crisis"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/montross.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Ourida"
    cover.author_last = "Mostefai"
    cover.author_id = "omostefa"
    cover.author_url = "#{host_url}/omostefa"
    cover.title = "Jean-Jacques Rousseau écrivain polémique"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Mostefai_Rousseau.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Jeffrey"
    cover.author_last = "Muller "
    cover.author_id = "jmmuller"
    cover.author_url = "#{host_url}/jmmuller"
    cover.title = "St. Jacob’s Antwerp Art and Counter Reformation in Rubens’s Parish Church"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Muller_StJacob.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Donald"
    cover.author_last = "Murphy"
    cover.author_id = "dmurphyd"
    cover.author_url = "#{host_url}/dmurphyd"
    cover.title = "Clinical Reasoning in Spine Pain Vol II:  Primary Management of Cervical Disorders Using the CRISP Protocol"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Murphy_ClinicalReasoning.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Itohan"
    cover.author_last = "Osayimwese"
    cover.author_id = "iosayimw"
    cover.author_url = "#{host_url}/iosayimw"
    cover.title = "Colonialism and Modern Architecture in Germany"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Osayimwese_Colonialism.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Keisha-Khan"
    cover.author_last = "Perry"
    cover.author_id = "kyperry"
    cover.author_url = "#{host_url}/kyperry"
    cover.title = "Black Women against the Land Grab: The Fight for Racial Justice in Brazil"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/perry.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Samuel"
    cover.author_last = "Perry "
    cover.author_id = "sperry"
    cover.author_url = "#{host_url}/sperry"
    cover.title = "Five Faces of Japanese Feminism: Crimson and Other Stories"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Perry_FiveFaces.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Carlos"
    cover.author_last = "Pittella"
    cover.author_id = "cpittell"
    cover.author_url = "#{host_url}/cpittell"
    cover.title = "Como Fernando Pessoa Pode Mudar a sua Vida."
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Pittella_ComoFernando.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Joseph"
    cover.author_last = "Pucci"
    cover.author_id = "jpucci"
    cover.author_url = "#{host_url}/jpucci"
    cover.title = "Augustine's Virgilian Retreat: Reading the Auctores at Cassiciacum"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/pucci.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Richard"
    cover.author_last = "Rambuss"
    cover.author_id = "rrambuss"
    cover.author_url = "#{host_url}/rrambuss"
    cover.title = "The English Poems of Richard Crashaw"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/rambuss.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Thangam"
    cover.author_last = "Ravindranathan"
    cover.author_id = "travindr"
    cover.author_url = "#{host_url}/travindr"
    cover.title = "Donner le change: l'impensé animal"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Ravindranathan_donner-le-change.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Marc"
    cover.author_last = "Redfield"
    cover.author_id = "mredfiel"
    cover.author_url = "#{host_url}/mredfiel"
    cover.title = "Theory at Yale: The Strange Case of Deconstruction in America"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/mredfiel.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Amy"
    cover.author_last = "Remensnyder"
    cover.author_id = "aremensn"
    cover.author_url = "#{host_url}/aremensn"
    cover.title = "La Conquistadora: The Virgin Mary at War and Peace in the Old and New Worlds"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/remensnyder.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Massimo"
    cover.author_last = "Riva"
    cover.author_id = "mriva"
    cover.author_url = "#{host_url}/mriva"
    cover.title = "Pico della Mirandola: Oration on the Dignity of Man. A New Translation and Commentary"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Riva_Pico.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Seth"
    cover.author_last = "Rockman"
    cover.author_id = "srockman"
    cover.author_url = "#{host_url}/srockman"
    cover.title = "Slavery’s Capitalism: A New History of American Economic Development"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Rockman_SlaverysCapitalism.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Brenda"
    cover.author_last = "Rubenstein"
    cover.author_id = "brubenst"
    cover.author_url = "#{host_url}/brubenst"
    cover.title = "Advances in the Computational Sciences: Symposium in Honor of Dr. Berni Alder's 90th Birthday"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Rubenstein_Advances.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Matthew"
    cover.author_last = "Rutz"
    cover.author_id = "mrutz"
    cover.author_url = "#{host_url}/mrutz"
    cover.title = "Bodies of Knowledge in Ancient Mesopotamia: The Diviners of Late Bronze Age Emar and their Tablet Collection"
    cover.pub_date = "2013"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/rutz.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Andrew"
    cover.author_last = "Scherer"
    cover.author_id = "as49"
    cover.author_url = "#{host_url}/as49"
    cover.title = "Mortuary Landscapes of the Classic Maya: Rituals of Body and Soul"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Scherer_Mortuary.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Wendy"
    cover.author_last = "Schiller"
    cover.author_id = "wschille"
    cover.author_url = "#{host_url}/wschille"
    cover.title = "Electing the Senate: Indirect Democracy before the Seventeenth Amendment"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Schiller_Electing.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Rebecca "
    cover.author_last = "Schneider"
    cover.author_id = "rcschnei"
    cover.author_url = "#{host_url}/rcschnei"
    cover.title = "Theatre & History"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/rcschnei.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Gretchen "
    cover.author_last = "Schultz"
    cover.author_id = "gschultz"
    cover.author_url = "#{host_url}/gschultz"
    cover.title = "Sapphic Fathers: Discourses of Same-Sex Desire from Nineteenth-Century France"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Schultz_Sapphic.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Lewis"
    cover.author_last = "Seifert"
    cover.author_id = "lseifert"
    cover.author_url = "#{host_url}/lseifert"
    cover.title = "Fairy Tales for the Disillusioned"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Seifert_FairyTales.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Naoko"
    cover.author_last = "Shibusawa"
    cover.author_id = "nshibusa"
    cover.author_url = "#{host_url}/nshibusa"
    cover.title = "Gender, Imperialism, and Global Exchanges"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Shibusawa_Gender.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "John"
    cover.author_last = "Steele"
    cover.author_id = "jmsteele"
    cover.author_url = "#{host_url}/jmsteele"
    cover.title = "Rising Time Schemes in Babylonian Astronomy"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Steele_RisingTimeSchemes.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Jeff"
    cover.author_last = "Titon"
    cover.author_id = "jtiton"
    cover.author_url = "#{host_url}/jtiton"
    cover.title = "Worlds of Music (6th edition)"
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Titon_WorldsofMusic.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Anthony"
    cover.author_last = "Vidler"
    cover.author_id = "avidler"
    cover.author_url = "#{host_url}/avidler"
    cover.title = "The Third Typology and Other Essays"
    cover.pub_date = "2015"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/vidler.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Marguerite"
    cover.author_last = "Vigliani"
    cover.author_id = "mviglian"
    cover.author_url = "#{host_url}/mviglian"
    cover.title = "A History of Medicine in 50 Discoveries."
    cover.pub_date = "2017"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Vigliani_HistoryOfMedicine.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Michael"
    cover.author_last = "White"
    cover.author_id = "miwhite"
    cover.author_url = "#{host_url}/miwhite"
    cover.title = "International Handbook of Migration and Population Distribution"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/White_Migration.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Andre"
    cover.author_last = "Willis"
    cover.author_id = "acw3"
    cover.author_url = "#{host_url}/acw3"
    cover.title = "Toward a Humean True Religion"
    cover.pub_date = "2014"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Willis_TowardAHumean.jpg"
    covers << cover

    cover = BookCoverModel.new()
    cover.author_first = "Samuel"
    cover.author_last = "Zipp"
    cover.author_id = "szipp"
    cover.author_url = "#{host_url}/szipp"
    cover.title = "Vital Little Plans: The Short Works of Jane Jacobs"
    cover.pub_date = "2016"
    cover.image = "https://vivo.brown.edu/themes/rab/images/books/Zipp_VitalLittlePlans.jpg"
    covers << cover

    covers
  end
end
