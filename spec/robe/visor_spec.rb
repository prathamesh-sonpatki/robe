require 'spec_helper'
require 'robe/visor'

describe Robe::Visor do
  let(:v) { described_class.new }

  context ".resolve_const" do
    it "resolves ARGF.class" do
      expect(v.resolve_const("ARGF.class")).to be(ARGF.class)
    end

    it "silently fails on nil" do
      expect(v.resolve_const(nil)).to be_nil
    end

    it "resolves simple constant" do
      expect(v.resolve_const("Object")).to be(Object)
    end

    it "resolves explicit global scope" do
      expect(v.resolve_const("::String")).to be(String)
    end

    it "resolves nested class" do
      expect(v.resolve_const("File::Stat")).to be(File::Stat)
    end

    it "swallows NameError" do
      expect(v.resolve_const("Foo::Bar")).to be_nil
    end
  end

  context ".resolve_context" do
    it "defaults to the module if no name" do
      expect(v.resolve_context(nil, "File")).to be(File)
    end

    it "accepts explicit scope qualifier" do
      expect(v.resolve_context("::String", "File")).to be(String)
    end

    it "sees nested constants" do
      expect(v.resolve_context("Stat", "File")).to be(File::Stat)
    end

    it "sees constants in containing scopes" do
      expect(v.resolve_context("Stat", "File::Constants")).to be(File::Stat)
    end

    it "returns nil when not found" do
      expect(v.resolve_context("Boo", "File::Constants")).to be_nil
    end

    it "prioritizes deeper nesting" do
      m = Module.new do
        module self::A; end
        module self::N
          module self::A
          end
        end
      end
      stub_const("M", m)
      expect(v.resolve_context("A", "M::N")).to be(m::N::A)
    end
  end

  context ".resolve_path_elems" do
    it "returns an array" do
      expect(v.resolve_path_elems(["File", "Stat"])).to eq([File, File::Stat])
    end
  end
end
