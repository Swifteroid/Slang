Pod::Spec.new do |spec|
  spec.name = 'Slang'
  spec.version = '0.1.1'
  spec.license = 'MIT'
  spec.summary = 'SourceKitten + Querying + Editing = 💖'
  spec.homepage = 'https://github.com/Swifteroid/Slang'
  spec.author = 'Ian Bytchek'
  spec.source = { :git => spec.homepage + '.git', :tag => spec.version }

  spec.osx.deployment_target  = '10.15'
  spec.swift_version = '5.2'

  spec.source_files = 'source/Slang/**/*.{swift,h,m}'
  spec.exclude_files = 'source/Slang/{Test}/**/*'

  spec.dependency 'SourceKittenFramework', '~> 0.29'
  spec.dependency 'STRegex', '~> 2.1'
end
