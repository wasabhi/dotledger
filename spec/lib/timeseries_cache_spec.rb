require 'timeseries_cache'

describe TimeseriesCache do
  let(:redis) { double('redis') }
  let(:key) { 'test_key' }
  let(:datetime) { DateTime.parse('2011-03-06 12:15:00') }
  let(:datetime_from) { DateTime.parse('2011-03-06') }
  let(:datetime_to) { DateTime.parse('2011-03-29') }
  let(:value) { "test value" }
  let(:prefixed_key) { "#{key}:some_timestamp" }
  let(:block) do
    proc { value }
  end

  subject { TimeseriesCache.new(key: key, redis: redis) }

  describe ".get" do
    context "value is set" do
      before do
        expect(subject).to receive(:set?).and_return(true)
        expect(redis).to receive(:get).and_return(subject.dump_value(value))
      end

      it "loads the value from redis" do
        expect(subject.get(datetime)).to eq value
      end
    end

    context "no value is set" do
      before do
        expect(subject).to receive(:set?).and_return(false)
      end

      it "raises an exception" do
        expect { subject.get(datetime) }.to raise_error TimeseriesCache::MissingValue
      end
    end
  end

  describe ".fetch" do
    context "value is set" do
      before do
        expect(subject).to receive(:get).and_return(value)
      end

      it "loads the value from redis" do
        expect(subject.fetch(datetime, &block)).to eq value
      end
    end

    context "no value is set" do
      before do
        expect(subject).to receive(:set?).and_return false
      end

      it "sets the value" do
        expect(subject).to receive(:set).with(datetime, &block)
        subject.fetch(datetime, &block)
      end
    end
  end

  describe ".fetch_range" do
    context "with no values set" do
      it "yields and sets the value the correct number of times" do
        expect(subject).to receive(:set?).exactly(24).times.and_return(false)
        expect(subject).to receive(:set).exactly(24).times.and_call_original
        allow(redis).to receive(:set)
        expect do |b|
          subject.fetch_range(datetime_from, datetime_to, &b)
        end.to yield_control.exactly(24).times
      end
    end

    context "with all values set" do
      it "does not yield and gets the value from redis the correct number of times" do
        expect(subject).to receive(:set?).exactly(24).times.and_return(true)
        expect(subject).to receive(:get).exactly(24).times.and_call_original
        allow(redis).to receive(:get).and_return(subject.dump_value(value))
        expect do |b|
          subject.fetch_range(datetime_from, datetime_to, &b)
        end.to_not yield_control
      end
    end
  end

  describe ".set" do
    before do
      expect(subject).to receive(:prefixed_key).with(datetime).and_return(prefixed_key)
    end

    context "with a value" do
      it "sets the value" do
        expect(redis).to receive(:set).with(prefixed_key, subject.dump_value(value))
        subject.set(datetime, value)
      end
    end

    context "with a block" do
      it "sets the value" do
        expect(redis).to receive(:set).with(prefixed_key, subject.dump_value(value))
        subject.set(datetime, &block)
      end
    end
  end

  describe ".set?" do
    before do
      expect(subject).to receive(:prefixed_key).with(datetime).and_return(prefixed_key)
    end

    it "checks if a key is set in redis" do
      expect(redis).to receive(:exists).with(prefixed_key)
      subject.set?(datetime)
    end
  end
end
