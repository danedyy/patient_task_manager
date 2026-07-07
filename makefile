fresh:
	@echo "🔧 Cleaning project..."
	fvm flutter clean
	@echo "🧹 Removing iOS Pods and Podfile.lock..."
	rm -rf ios/Pods ios/Podfile.lock
	@echo "📦 Fetching Flutter dependencies..."
	fvm flutter pub get
	@echo "✅ Project fully cleaned and refreshed!"

build-runner:
	@echo "🔧 Running build_runner..."
	fvm dart run build_runner build --delete-conflicting-outputs
	@echo "✅ Code generation complete!"

valid-dep:
	@echo "🔧 Running dependency_validator..."
	fvm dart run dependency_validator
	@echo "✅ Dependency validation complete!"

lint:
	@echo "🔧 Running lints..."
	fvm dart run custom_lint
	@echo "✅ Linting complete!"

format-code: fix-lint
	@echo "🔧 Running formatting..."
	fvm dart format .
	@echo "✅ Formatting complete!"

fix-lint:
	@echo "🔧 Running lint fixes..."
	fvm dart fix --apply
	@echo "✅ Lint fixes complete!"