require "./app/models/book_cover_sample_data.rb"
class BookCoverModel
  attr_accessor :author_first, :author_last, :author_id, :author_url,
    :title, :pub_date, :image

  @@covers_paginated = nil

  def self.get_all_paginated(author_base_url, page_size)
    # TODO: Use the Rails cache for this
    @@covers_paginated ||= begin
      Rails.logger.info "Calculating paginated covers..."
      covers = get_all(author_base_url)
      pages = []
      page = []
      covers.each do |cover|
        page << cover
        if page.count == page_size
          pages << page
          page = []
        end
      end
      if page.count > 0
        pages << page
      end
      pages
    end
  end

  def self.get_all(author_base_url)
    if ENV["BOOK_COVER_STUB"]=="true"
      BookCoversSampleData.get_all()
    else
      self.get_all_from_db(author_base_url)
    end
  end

  def self.get_all_from_db(author_base_url)
    base_path = ENV["BOOK_COVER_BASE_PATH"]
    if base_path == nil
      Rails.logger.error "BOOK_COVER_BASE_PATH has not been defined. Book covers will not be available."
      return []
    end
    covers = []
    Rails.logger.info "Fetching covers from the database..."
    sql = <<-END_SQL.gsub(/\n/, '')
      SELECT jacket_id, firstname, lastname, shortID, title, pub_date,
      image, dept, dept2, dept3, active
      FROM book_covers
      WHERE active = 'y'
      ORDER BY pub_date DESC
    END_SQL
    rows = ActiveRecord::Base.connection.exec_query(sql)
    rows.each do |row|
      cover = BookCoverModel.new()
      cover.author_first = row['firstname']
      cover.author_last = row['lastname']
      cover.author_id = row['shortID']
      cover.author_url = "#{author_base_url}#{row['shortID']}"
      cover.title = row['title']
      cover.pub_date = row['pub_date']
      cover.image = "#{base_path}/#{row['image']}"
      covers << cover
    end
    covers
  rescue => ex
    Rails.logger.error "#{ex.message}"
    []
  end

  def self.delete_all!()
    sql = "DELETE FROM book_covers;"
    ActiveRecord::Base.connection.execute(sql)
    Rails.logger.info "Deleted all book covers from the database"
  end

  def self.import_file(file_name)
    columns, rows = self.read_tsv_file(file_name)
    rows.each do |row|
      sql = self.sql_insert(row)
      ActiveRecord::Base.connection.execute(sql)
    end
    Rails.logger.info "Imported #{rows.count} book covers..."
  end

  def self.init_default_data()
    if book_covers_cache_count() > 0
      puts "Book covers cache has already been initialized."
      return
    end

    puts "Initializing book covers cache..."
    sql = <<-END_SQL.gsub(/\n/, '')
      INSERT INTO `book_covers` (`jacket_id`, `firstname`, `lastname`, `shortID`, `title`, `pub_date`, `image`, `role`, `dept`, `dept2`, `dept3`, `active`) VALUES
      (1, 'James', 'Allen', 'jpallen', 'Middle Egyptian Literature: Eight Literary Works of the Middle Kingdom', 2015, 'Allen_MiddleEgyptianLiterature.jpg', 'author', 'Egyptology and Assyriology', '', '', 'y'),
      (2, 'Peter', 'Andreas', 'pandreas', 'Rebel Mother: My Childhood Chasing the Revolution', 2017, 'Andreas_RebelMother.jpg', 'author', 'Political Science', 'International and Public Affairs', '', 'y'),
      (3, 'Richard', 'Arenberg', 'rarenber', 'Defending the Filibuster: The Soul of the Senate, Revised and Updated', 2014, 'Arenberg_DefendingTheFilibuster.jpg', 'author', 'Political Science', '', '', 'y'),
      (4, 'Paul', 'Armstrong', 'pbarmstr', 'Norton Critical Edition of Joseph Conrad, Heart of Darkness, 5th ed', 2016, 'Armstrong_HeartofDarkness.jpg', 'author', 'English', '', '', 'y'),
      (5, 'Nomy', 'Arpaly', 'narpaly', 'In Praise of Desire by Nomy Arpaly', 2013, 'arpaly.jpg', 'author', 'Philosophy', '', '', 'y'),
      (6, 'Ethan', 'Balk', 'ebalk', 'Benefits and Harms of Routine Preoperative Testing', 2014, 'Balk_BenefitsAndHarms.jpg', 'author', 'Health Services, Policy and Practice', '', '', 'y'),
      (7, 'Omer', 'Bartov', 'obartov', 'The Holocaust: Origins, Implementation, Aftermath, 2nd Edition', 2015, 'Bartov_Holocaust.jpg', 'author', 'History', 'German Studies', '', 'y'),
      (8, 'Adia', 'Benton', 'abenton', 'HIV Exceptionalism: Development through Disease in Sierra Leone', 2015, 'abenton.jpg', 'author', 'Anthropology', '', '', 'y'),
      (9, 'Mutlu ', 'Blasing', 'mblasing', 'Nazim Hikmet: The Life and Times of Turkey''s World Poet', 2013, 'blasing.jpg', 'author', 'English', '', '', 'y'),
      (10, 'Mark', 'Blyth', 'mblyth', 'Austerity: The History of a Dangerous Idea', 2013, 'blyth.jpg', 'author', 'Political Science', 'International and Public Affairs', '', 'y'),
      (11, 'Elizabeth', 'Brainerd', 'ebrainer', 'Great Transformations in Vertebrate Evolution', 2015, 'Brainerd_GreatTransformations.jpg', 'author', 'Ecology and Evolutionary Biology', '', '', 'y'),
      (12, 'Lundy', 'Braun', 'lbraun', 'Breathing Race into the Machine', 2014, 'lbraun.jpg', 'author', 'Pathology and Laboratory Medicine', 'Africana Studies', '', 'y'),
      (13, 'Stephen', 'Bush', 'sb5', 'Visions of Religion: Experience, Meaning, and Power', 2014, 'Bush_VisionsOfReligion.jpg', 'author', 'Religious Studies', '', '', 'y'),
      (14, 'Melani C.', 'Cammett', 'mcammett', 'Compassionate Communalism, Welfare and Sectarianism in Lebanon', 2014, 'cammett.jpg', 'author', 'Political Science', '', '', 'y'),
      (15, 'Caroline ', 'Castiglione', 'ccastigl', 'Accounting for Affection: Mothering and Politics in Early Modern Rome', 2014, 'Castiglione_AccountingForAffection.jpg', 'author', 'History', 'Italian Studies', '', 'y'),
      (16, 'Colin', 'Channer', 'cchanner', 'Providential', 2015, 'Channer_Providential.jpg', 'author', 'Literary Arts', '', '', 'y'),
      (17, 'Ross', 'Cheit', 'rcheit', 'The Witch-Hunt Narrative: Politics, Psychology, and the Sexual Abuse of Children', 2014, 'cheit.jpg', 'author', 'Political Science', 'International and Public Affairs', '', 'y'),
      (18, 'Tamara', 'Chin', 'tc69', 'Savage Exchange: Han Imperialism, Chinese Literary Style, and the Economic Imagination', 2014, 'Chin_SavageExchange.jpg', 'author', 'Comparative Literature', '', '', 'y'),
      (19, 'David', 'Christensen', 'dchriste', 'The Epistemology of Disagreement: New Essays', 2013, 'Christensen_Epistemology.jpg', 'author', 'Philosophy', '', '', 'y'),
      (20, 'Howard', 'Chudacoff', 'hchudaco', 'Changing the Playbook: How Power, Profit, and Politics Transformed College Sports', 2015, 'hchudaco.jpg', 'author', 'History', 'Urban Studies', '', 'y'),
      (21, 'Wendy', 'Chun', 'wchun', 'New Media, Old Media: A History and Theory Reader', 2015, 'Chun_NewMedia.jpg', 'author', 'Modern Culture and Media', '', '', 'y'),
      (22, 'Barry', 'Connors', 'bconnors', 'Neuroscience: Exploring the Brain, 4th ed. ', 2015, 'Connors_Neuroscience.jpg', 'author', 'Neuroscience', '', '', 'y'),
      (23, 'Harold', 'Cook', 'hjcook', 'Ways of Making and Knowing: The Material Culture of Empirical Knowledge', 2014, 'Cook_WaysOfMakingAndKnowing.jpg', 'author', 'History', '', '', 'y'),
      (24, 'Robert', 'Coover', 'rcoover', 'Brunist Day of Wrath by Robert Coover', 2014, 'coover.jpg', 'author', 'Literary Arts (Emeritus)', '', '', 'y'),
      (25, 'Eric', 'Darling', 'ed12', 'Articular Cartilage, Second Edition', 2017, 'Darling_ArticularCartilage.jpg', 'author', 'Medical Science', 'Engineering', 'Orthopaedics', 'y'),
      (26, 'Nicola', 'Denzey', 'ndenzey', 'Cosmology and Fate in Gnosticism and the Graeco-Roman World: Under A Pitiless Sky', 2013, 'Denzey_CosmologyAndFate.jpg', 'author', 'Religious Studies', '', '', 'y'),
      (27, 'Paja', 'Faudree', 'pfaudree', 'Singing for the Dead: The Politics of Indigenous Revival in Mexico ', 2013, 'faudree.jpg', 'author', 'Anthropology', '', '', 'y'),
      (28, 'Thalia', 'Field', 'tfield', 'Experimental Animals: A Reality Fiction', 2016, 'Field_ExperimentalAnimals.jpg', 'author', 'Literary Arts', '', '', 'y'),
      (29, 'Linford', 'Fisher', 'lf7', 'Decoding Roger Williams: The Lost Essay of Rhode Island''s Founding Father', 2014, 'Fisher_DecodingRogerWilliams.jpg', 'author', 'History', '', '', 'y'),
      (30, 'Caroline ', 'Frank', 'cfrank', 'Global Trade and Visual Arts in Federal New England ', 2014, 'Frank_GlobalTrade.jpg', 'author', '', '', '', 'n'),
      (31, 'Hannah', 'Freed-Thall', 'hfreedth', 'Spoiled Distinctions: Aesthetics and the Ordinary in French Modernism', 2015, 'Freed-Thall_SpoiledDistinctions.jpg', 'author', '', '', '', 'n'),
      (32, 'Forrest ', 'Gander', 'fgander', 'The Trace', 2014, 'Gander_trace.jpg', 'author', 'Literary Arts', 'Comparative Literature', '', 'y'),
      (33, 'Leela', 'Gandhi', 'lgandhi', 'The Common Cause: Postcolonial Ethics and the Practice of Democracy, 1900-1955 ', 2014, 'Gandhi_TheCommonCause.jpg', 'author', 'English', '', '', 'y'),
      (34, 'Eric', 'Gartman', 'egartman', 'Ultrasound in the Intensive Care Unit', 2014, 'Gartman_UltrasoundInTheIntensiveCareUnit.jpg', 'author', 'Medicine', '', '', 'y'),
      (35, 'Victor', 'Golstein', 'vgolstei', 'Svetlana Aleksijevitj – Sovjetintelligentians Röst (The Voice of Soviet Intelligentsia)', 2015, 'Golstein_Svetlana.jpg', 'author', 'Slavic Studies', '', '', 'y'),
      (36, 'Spencer', 'Golub', 'sgolub', 'Incapacity: Wittgenstein, Anxiety, and Performance Behavior ', 2014, 'sgolub.jpg', 'author', 'Theatre Arts and Performance Studies', '', '', 'y'),
      (37, 'Philip', 'Gould', 'pgould', 'Writing the Rebellion: Loyalists and the Literature of Politics in British America', 2013, 'gould.jpg', 'author', 'English', '', '', 'y'),
      (38, 'James', 'Green', 'jngreen', 'Ditadura e homossexualidades : repressão, resistência e a busca da verdade', 2014, 'Green_Ditadura.jpg', 'author', 'History', 'Portuguese and Brazilian Studies', '', 'y'),
      (39, 'Jo', 'Guldi', 'eguldi', 'The History Manifesto', 2014, 'Guldi_TheHistoryManifesto.jpg', 'author', 'History', '', '', 'y'),
      (40, 'Matthew', 'Guterl', 'mguterl', 'Hotel Life: The Story of a Place Where Anything Can Happen', 2015, 'Guterl_HotelLife.jpg', 'author', 'Africana Studies', 'American Studies', '', 'y'),
      (41, 'Matthew', 'Gutmann', 'mgutmann', 'Global Latin America: Into the Twenty-First Century', 2016, 'Gutmann_GlobalLatinAmerica.jpg', 'author', 'Anthropology', '', '', 'y'),
      (42, 'Françoise', 'Hamlin', 'fhamlin', 'These Truly Are The Brave: An Anthology of African American Writings on War and Citizenship', 2015, 'Hamlin_TheseTrulyAreTheBrave.jpg', 'author', 'Africana Studies', 'History', '', 'y'),
      (43, 'Johanna', 'Hanink', 'jhanink', 'The Classical Debt: Greek Antiquity in an Era of Austerity', 2017, 'Hanink_ClassicalDebt.jpg', 'author', 'Classics', '', '', 'y'),
      (44, 'Ömür ', 'Harmanşah', 'oharmans', 'Place, Memory, and Healing: An Archaeology of Anatolian Rock Monuments ', 2014, 'Harmansah_PlaceMemoryAndHealing.jpg', 'author', 'Archaeology and the Ancient World', 'Egyptology and Ancient Western Asian Studies', '', 'y'),
      (45, 'Tim', 'Harris', 'tgharris', 'Rebellion: Britain''s First Stuart Kings, 1567-1642', 2014, 'harris.jpg', 'author', 'History', '', '', 'y'),
      (46, 'Kenneth', 'Haynes', 'khaynes', 'Broken Hierarchies: Collected Poems 1952-2012', 2014, 'haynes.jpg', 'author', 'Classics', 'Comparative Literature', '', 'y'),
      (47, 'Stephen', 'Houston', 'shouston', 'The Life Within: Classic Maya and the Matter of Permanence', 2014, 'houston.jpg', 'author', 'Anthropology', 'Archaeology and the Ancient World', '', 'y'),
      (48, ' Catherine ', 'Imbriglio', 'cimbrigl', 'Intimacy', 2013, 'imbriglio.jpg', 'author', 'English', '', '', 'y'),
      (49, 'Donald', 'Jackson', 'dcjackso', 'Celebrating Life: An Appreciation of Animals in Verse and Prose ', 2013, 'Jackson_Celebrating.jpg', 'author', 'Molecular Pharmacology ', 'Physiology and Biotechnology', '', 'y'),
      (50, 'Nancy', 'Jacobs', 'njacobs', 'Birders of Africa: History of a Network ', 2016, 'Jacobs_BirdersOfAfrica.jpg', 'author', 'Africana Studies', 'History', '', 'y'),
      (51, 'David', 'Kertzer', 'dkertzer', 'The Pope and Mussolini', 2014, 'kertzer.jpg', 'author', 'Anthropology', 'Italian Studies', '', 'y'),
      (52, 'Jacques', 'Khalip', 'jkhalip', 'Constellations of a Contemporary Romanticism', 2016, 'Khalip_Constellations.jpg', 'author', 'English', '', '', 'y'),
      (53, 'Daniel', 'Kim', 'dakim', 'The Cambridge Companion to Asian American Literature', 2015, 'Kim_Cambridge.jpg', 'author', 'English', 'American Studies', '', 'y'),
      (54, 'Thomas', 'Kniesche', 'tkniesch', 'Einführung in den Kriminalroman', 2015, 'Kniesche_Einfuhrung.jpg', 'author', 'German Studies', '', '', 'y'),
      (55, 'Peter', 'Kramer', 'pkramerm', 'Ordinarily Well: The Case for Antidepressants', 2016, 'Kramer_OrdinarilyWell.jpg', 'author', 'Psychiatry and Human Behavior', '', '', 'y'),
      (56, 'George', 'Kroumpouzos', 'gkroumpo', 'Text Atlas of Obstetric Dermatology', 2013, 'Kroumpouzos_TextAtlasOfObstetricDermatology.jpg', 'author', 'Dermatology', '', '', 'y'),
      (57, 'James', 'Kuzner', 'jkuzner', 'Shakespeare as a Way of Life: Skeptical Practice and the Politics of Weakness', 2016, 'Kuzner_ShakespeareAsAWayOfLife.jpg', 'author', 'English', '', '', 'y'),
      (58, 'Jessaca ', 'Leinaweaver', 'jleinawe', 'Adoptive Migration: Raising Latinos in Spain', 2013, 'leinaweaver.jpg', 'author', 'Anthropology', 'Latin American and Caribbean Studies', '', 'y'),
      (59, 'Philip', 'Lieberman', 'plieberm', 'The Unpredictable Species: What Makes Humans Unique ', 2013, 'plieberm.jpg', 'author', 'Cognitive, Linguistic, and Psychological Sciences', '', '', 'y'),
      (60, 'Eng-Beng', 'Lim', 'el46', 'Brown Boys and Rice Queens: Spellbinding Performance in the Asias ', 2013, 'lim.jpg', 'author', 'Theatre Arts and Performance Studies', '', '', 'y'),
      (61, 'Evelyn', 'Lincoln', 'elincoln', 'Brilliant Discourse: Pictures and Readers in Early Modern Rome', 2014, 'lincoln.jpg', 'author', 'History of Art and Architecture', 'Italian Studies', '', 'y'),
      (62, 'Steven', 'Lubar', 'slubar', 'Inside the Lost Museum: Curating, Past and Present', 2017, 'Lubar_LostMuseum.jpg', 'author', 'American Studies', 'History', 'History of Art and Architecture', 'y'),
      (63, 'Catherine', 'Lutz', 'clutz', 'Schooled: Ordinary, Extraordinary Teaching in an Age of Change', 2015, 'clutz.jpg', 'author', 'Anthropology', 'International and Public Affairs', '', 'y'),
      (64, 'Maud', 'Mandel', 'mmandel', 'Muslims and Jews in France ', 2014, 'mandel.jpg', 'author', 'History', 'Judaic Studies', '', 'y'),
      (65, 'Courtney', 'Martin', 'cm40', 'Lawrence Alloway: Critic and Curator', 2015, 'Martin_LawrenceAlloway.jpg', 'author', 'History of Art and Architecture', '', '', 'y'),
      (66, 'Felipe', 'Martinez-Pinzon', 'fmartin1', 'Una cultura de invernadero: trópico y civilización en Colombia (1808-1928)', 2016, 'Martinez_Pinzon_UnaCultura.jpg', 'author', 'Hispanic Studies', '', '', 'y'),
      (67, 'Katherine', 'Mason', 'kam6', 'Infectious Change: Reinventing Chinese Public Health after an Epidemic', 2016, 'Mason_Infectious.jpg', 'author', 'Anthropology', '', '', 'y'),
      (68, 'Kevin', 'McLaughlin', 'kmclaugh', 'Poetic Force: Poetry after Kant', 2014, 'McLaughlin_PoeticForce.jpg', 'author', 'English', 'Comparative Literature', '', 'y'),
      (69, 'RIchard', 'Meckel', 'rmeckel', 'Save the Babies: American Public Health Reform and the Prevention of Infant Mortality, 1850-1929', 2015, 'Meckel_SaveTheBabies.jpg', 'author', 'American Studies', '', '', 'y'),
      (70, 'Brian', 'Meeks', 'bmeeks', 'Freedom, Power and Sovereignty: The Thought of Gordon K. Lewis ', 2015, 'Meeks_Freedom.jpg', 'author', 'Africana Studies', '', '', 'y'),
      (71, 'Christine', 'Montross', 'cmontros', 'Falling Into the Fire: A Psychiatrist''s Encounters with the Mind in Crisis', 2013, 'montross.jpg', 'author', 'Psychiatry and Human Behavior', '', '', 'y'),
      (72, 'Ourida', 'Mostefai', 'omostefa', 'Jean-Jacques Rousseau écrivain polémique', 2016, 'Mostefai_Rousseau.jpg', 'author', 'Comparative Literature', 'French Studies', '', 'y'),
      (73, 'Jeffrey', 'Muller ', 'jmmuller', 'St. Jacob’s Antwerp Art and Counter Reformation in Rubens’s Parish Church', 2016, 'Muller_StJacob.jpg', 'author', 'History of Art and Architecture', '', '', 'y'),
      (74, 'Donald', 'Murphy', 'dmurphyd', 'Clinical Reasoning in Spine Pain Vol II:  Primary Management of Cervical Disorders Using the CRISP Protocol', 2016, 'Murphy_ClinicalReasoning.jpg', 'author', 'Family Medicine', '', '', 'y'),
      (75, 'Itohan', 'Osayimwese', 'iosayimw', 'Colonialism and Modern Architecture in Germany', 2017, 'Osayimwese_Colonialism.jpg', 'author', 'History of Art and Architecture', '', '', 'y'),
      (76, 'Keisha-Khan', 'Perry', 'kyperry', 'Black Women against the Land Grab: The Fight for Racial Justice in Brazil', 2013, 'perry.jpg', 'author', 'Africana Studies', '', '', 'y'),
      (77, 'Samuel', 'Perry ', 'sperry', 'Five Faces of Japanese Feminism: Crimson and Other Stories', 2016, 'Perry_FiveFaces.jpg', 'author', 'East Asisn Studies', '', '', 'y'),
      (78, 'Carlos', 'Pittella', 'cpittell', 'Como Fernando Pessoa Pode Mudar a sua Vida.', 2016, 'Pittella_ComoFernando.jpg', 'author', 'Portuguese and Brazilian Studies', '', '', 'y'),
      (79, 'Joseph', 'Pucci', 'jpucci', 'Augustine''s Virgilian Retreat: Reading the Auctores at Cassiciacum', 2014, 'pucci.jpg', 'author', 'Classics', 'Comparative Literature', '', 'y'),
      (80, 'Richard', 'Rambuss', 'rrambuss', 'The English Poems of Richard Crashaw', 2013, 'rambuss.jpg', 'author', 'English', '', '', 'y'),
      (81, 'Thangam', 'Ravindranathan', 'travindr', 'Donner le change: l''impensé animal', 2016, 'Ravindranathan_donner-le-change.jpg', 'author', 'French Studies', '', '', 'y'),
      (82, 'Marc', 'Redfield', 'mredfiel', 'Theory at Yale: The Strange Case of Deconstruction in America', 2015, 'mredfiel.jpg', 'author', 'Comparative Literature', 'English', '', 'y'),
      (83, 'Amy', 'Remensnyder', 'aremensn', 'La Conquistadora: The Virgin Mary at War and Peace in the Old and New Worlds', 2013, 'remensnyder.jpg', 'author', 'History', '', '', 'y'),
      (84, 'Massimo', 'Riva', 'mriva', 'Pico della Mirandola: Oration on the Dignity of Man. A New Translation and Commentary', 2016, 'Riva_Pico.jpg', 'author', 'Italian Studies', '', '', 'y'),
      (85, 'Seth', 'Rockman', 'srockman', 'Slavery’s Capitalism: A New History of American Economic Development', 2016, 'Rockman_SlaverysCapitalism.jpg', 'author', 'History', '', '', 'y'),
      (86, 'Brenda', 'Rubenstein', 'brubenst', 'Advances in the Computational Sciences: Symposium in Honor of Dr. Berni Alder''s 90th Birthday', 2017, 'Rubenstein_Advances.jpg', 'author', 'Chemistry', '', '', 'y'),
      (87, 'Matthew', 'Rutz', 'mrutz', 'Bodies of Knowledge in Ancient Mesopotamia: The Diviners of Late Bronze Age Emar and their Tablet Collection', 2013, 'rutz.jpg', 'author', 'Egyptology and Assyriology', '', '', 'y'),
      (88, 'Andrew', 'Scherer', 'as49', 'Mortuary Landscapes of the Classic Maya: Rituals of Body and Soul', 2015, 'Scherer_Mortuary.jpg', 'author', 'Anthropology', 'Archaeology and the Ancient World', '', 'y'),
      (89, 'Wendy', 'Schiller', 'wschille', 'Electing the Senate: Indirect Democracy before the Seventeenth Amendment', 2014, 'Schiller_Electing.jpg', 'author', 'Political Science', 'International and Public Affairs', '', 'y'),
      (90, 'Rebecca ', 'Schneider', 'rcschnei', 'Theatre & History', 2014, 'rcschnei.jpg', 'author', 'Theatre Arts and Performance Studies', '', '', 'y'),
      (91, 'Gretchen ', 'Schultz', 'gschultz', 'Sapphic Fathers: Discourses of Same-Sex Desire from Nineteenth-Century France', 2015, 'Schultz_Sapphic.jpg', 'author', 'French Studies', '', '', 'y'),
      (92, 'Lewis', 'Seifert', 'lseifert', 'Fairy Tales for the Disillusioned', 2017, 'Seifert_FairyTales.jpg', 'author', 'French Studies', '', '', 'y'),
      (93, 'Naoko', 'Shibusawa', 'nshibusa', 'Gender, Imperialism, and Global Exchanges', 2015, 'Shibusawa_Gender.jpg', 'author', 'History', 'American Studies', '', 'y'),
      (94, 'John', 'Steele', 'jmsteele', 'Rising Time Schemes in Babylonian Astronomy', 2017, 'Steele_RisingTimeSchemes.jpg', 'author', 'Egyptology and Assyriology', '', '', 'y'),
      (95, 'Jeff', 'Titon', 'jtiton', 'Worlds of Music (6th edition)', 2017, 'Titon_WorldsofMusic.jpg', 'author', 'Music', '', '', 'y'),
      (96, 'Anthony', 'Vidler', 'avidler', 'The Third Typology and Other Essays', 2015, 'vidler.jpg', 'author', 'History of Art and Architecture', '', '', 'y'),
      (98, 'Marguerite', 'Vigliani', 'mviglian', 'A History of Medicine in 50 Discoveries.', 2017, 'Vigliani_HistoryOfMedicine.jpg', 'author', 'Obstetrics and Gynecology', '', '', 'y'),
      (99, 'Michael', 'White', 'miwhite', 'International Handbook of Migration and Population Distribution', 2016, 'White_Migration.jpg', 'author', 'Sociology', 'Population Studies & Training Center', '', 'y'),
      (100, 'Andre', 'Willis', 'acw3', 'Toward a Humean True Religion', 2014, 'Willis_TowardAHumean.jpg', 'author', 'Religious Studies', '', '', 'y'),
      (101, 'Samuel', 'Zipp', 'szipp', 'Vital Little Plans: The Short Works of Jane Jacobs', 2016, 'Zipp_VitalLittlePlans.jpg', 'author', 'American Studies', 'Urban Studies', '', 'y');
    END_SQL
    ActiveRecord::Base.connection.execute(sql)
    count = book_covers_cache_count()
    puts "#{count} rows were inserted to the book covers cache."
  end

  def self.add_one()
    sql = <<-END_SQL.gsub(/\n/, '')
      INSERT INTO `book_covers` (`firstname`, `lastname`, `shortID`, `title`, `pub_date`, `image`, `role`, `dept`, `active`) VALUES
        ('Faiz', 'Ahmed', 'fa8', 'Afghanistan Rising Islamic Law and Statecraft between the Ottoman and British Empires', 2017, 'ahmed_afghanistan_rising.jpg', 'author', 'History', 'y');
    END_SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "Added new hard-coded book cover."
  end

  def self.book_covers_cache_count()
    rows = ActiveRecord::Base.connection.exec_query('SELECT count(*) AS count FROM book_covers;')
    rows.first["count"]
  end

  private
    def self.read_tsv_file(file_name)
      columns = []
      rows = []
      File.open(file_name, "r") do |f|
        line_no = 0
        f.each_line do |line|
          line_no += 1
          tokens = line.split("\t")

          if line_no == 1
            columns == tokens
          else
            rows << tokens
          end
        end
      end
      return [columns, rows]
    end

    def self.sql_insert(row)
      # notice that we ignore the first two columns (id and jacket_id)
      firstname = str_value(row[2])
      lastname = str_value(row[3])
      shortID = str_value(row[4])
      title = str_value(row[5])
      pub_date = row[6]
      image = str_value(row[7])
      role = str_value(row[8])
      dept = str_value(row[9])
      dept2 = str_value(row[10])
      dept3 = str_value(row[11])
      active = str_value(row[12])

      sql = <<-END_SQL.gsub(/\n/, '')
        INSERT INTO book_covers (firstname, lastname, shortID, title, pub_date, image, role, dept, dept2, dept3, active)
        VALUES (#{firstname}, #{lastname}, #{shortID}, #{title}, #{pub_date}, #{image}, #{role}, #{dept}, #{dept2}, #{dept3}, #{active});
      END_SQL
    end

    def self.str_value(val)
      '"' + val.gsub('"', '""') + '"'
    end
end
