describe ThemeJuice::Config do

  before :each do
    @config = ThemeJuice::Config
    expect_any_instance_of(@config).to receive(:config)
      .once.and_return YAML.load %Q{
commands:
  install:
    - "%args%"
  watch: "%arguments%"
  assets:
    - "%argument1"
  vendor:
    - "1:%arg1% 2:%arg2%"
    - "3:%arg3% 4:%arg4%"
  wp:
    - "1:%argument1% 2:%argument2%"
  backup:
    - "1:%argument1% 4:%argument4%"
  dist:
    - "1:%argument1% 2:%argument2% 3:%argument3% 4:%argument4%"
}
  end

  describe ".method_missing" do

    context "when receiving an unknown method" do

      it "should not raise error if method exists in config" do
        allow(stdout).to receive :print
        expect { @config.command :install }.not_to raise_error
      end

      it "should raise error if method does not exist in config and Env.verbose is true" do
        allow(ThemeJuice::Env).to receive(:trace).and_return true
        capture(:stdout) do
          expect { @config.command :invalid }.to raise_error NotImplementedError
        end
      end

      it "should output notice to $stdout if config is invalid" do
        capture(:stdout) do
          expect { @config.command :watch }.to output.to_stdout
        end
      end

      it "should not raise error if config is invalid" do
        capture(:stdout) do
          expect { @config.command :watch }.not_to raise_error
        end
      end
    end

    context "when receiving a method that exists in config" do

      it "should map all args to single command" do
        allow(stdout).to receive :print
        expect { @config.command :install, ["1", "2", "3", "4"] }.to output(/1 2 3 4/).to_stdout
      end

      it "should map each arg to specific command" do
        allow(stdout).to receive :print
        expect { @config.command :dist, ["1", "2", "3", "4"] }.to output(/1:1 2:2 3:3 4:4/).to_stdout
      end

      it "should handle running multiple commands" do
        allow(stdout).to receive :print
        expect { @config.command :vendor, ["1", "2", "3", "4"] }.to output(/(1:1 2:2)(.*)?(3:3 4:4)/m).to_stdout
      end
    end
  end
end
