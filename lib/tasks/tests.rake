namespace :vivo do
  desc "VIVO tests"
  task :tests do
    Dir.glob('./test/**/*_test.rb').each do |file|
      require file
    end
  end
end
