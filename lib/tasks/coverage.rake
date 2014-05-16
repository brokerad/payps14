desc "Generating code coverage report"
task :generate_code_coverage do
	# Cleaning prevoius execution
	sh %{ rm -rf public/coverage/ }

	# Running rake spec:rcov
	Rake::Task["spec:rcov"].invoke
	
	# Moving coverage report to public folder
	sh %{ mv coverage public }
end
