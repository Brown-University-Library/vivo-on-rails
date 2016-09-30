namespace :vivo do
  desc "Run all the tests"
  task :tests do
    Dir.glob('./test/**/*_test.rb').each do |file|
      require file
    end
  end
end
