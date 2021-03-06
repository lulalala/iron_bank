# frozen_string_literal: true

RSpec.describe IronBank::Configuration do
  let(:default_schema) { "./config/schema" }
  let(:default_export) { "./config/export" }
  let(:configuration)  { described_class.new }

  describe "#schema_directory" do
    subject { configuration.schema_directory }
    it { is_expected.to eq(default_schema) }
  end

  describe "#schema_directory=" do
    let(:schema_directory) { anything }
    subject(:set_schema)   { configuration.schema_directory = schema_directory }

    it "changes the instance variable" do
      expect { set_schema }.
        to change(configuration, :schema_directory).
        from(default_schema).
        to(schema_directory)
    end

    it "resets the imported schema" do
      expect(IronBank::Schema).to receive(:reset)
      set_schema
    end

    it "resets each resource, except modules" do
      IronBank::Resources.constants.each do |resource|
        klass = IronBank::Resources.const_get(resource)
        next unless klass.is_a?(Class)

        expect(klass).to receive(:with_schema).twice
      end

      set_schema
    end
  end

  describe "#export_directory" do
    subject { configuration.export_directory }
    it { is_expected.to eq(default_export) }
  end

  describe "#export_directory=" do
    let(:export_directory) { anything }

    subject(:set_export) { configuration.export_directory = export_directory }

    it "changes the instance variable" do
      expect { set_export }.
        to change(configuration, :export_directory).
        from(default_export).
        to(export_directory)
    end

    it "resets the local store for each resource defined in LocalRecords" do
      %w[
        Product
        ProductRatePlan
        ProductRatePlanCharge
        ProductRatePlanChargeTier
      ].each do |resource|
        klass = IronBank::Resources.const_get(resource)
        expect(klass).to receive(:reset_store)
      end

      set_export
    end
  end

  describe "#excluded_fields" do
    subject(:excluded_fields) { configuration.excluded_fields }

    before { configuration.excluded_fields_file = filepath }

    context "no file specified" do
      let(:filepath) { nil }
      it { is_expected.to eq({}) }
    end

    context "file not present" do
      let(:filepath) { "missing.yml" }

      before { allow(IronBank.logger).to receive(:warn) }

      it { is_expected.to eq({}) }

      it "warns the user" do
        excluded_fields

        expect(IronBank.logger).
          to have_received(:warn).
          with("File does not exist: #{filepath}")
      end
    end

    context "file specified, YAML containing a hash" do
      let(:filepath) { "spec/fixtures/valid_excluded_fields.yml" }

      it { is_expected.to be_a(Hash) }
    end

    context "file specified, but YAML does not contain a hash" do
      let(:filepath) { "spec/fixtures/invalid_excluded_fields.yml" }

      specify do
        expect { excluded_fields }.
          to raise_error(RuntimeError, "Excluded fields must be a hash")
      end
    end
  end
end
