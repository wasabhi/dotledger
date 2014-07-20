require 'spec_helper'
require 'timeseries_cache/timeseries_cache'

describe TimeseriesCache::Year do
  let(:redis) { double('redis') }
  let(:key) { 'test_key' }
  let(:datetime_from) { DateTime.parse('2011-03-01') }
  let(:datetime_to) { DateTime.parse('2014-01-01') }
  let(:value) { "test value" }

  subject { TimeseriesCache::Year.new(key: key, redis: redis) }

  describe ".fetch_range" do
    context "with no values set" do
      it "yields and sets the value the correct number of times" do
        expect(subject).to receive(:set?).exactly(4).times.and_return(false)
        expect(subject).to receive(:set).exactly(4).times.and_call_original
        allow(redis).to receive(:set)
        expect do |b|
          a = subject.fetch_range(datetime_from, datetime_to, &b)
        end.to yield_control.exactly(4).times
      end
    end

    context "with all values set" do
      it "does not yield and gets the value from redis the correct number of times" do
        expect(subject).to receive(:set?).exactly(4).times.and_return(true)
        expect(subject).to receive(:get).exactly(4).times.and_call_original
        allow(redis).to receive(:get).and_return(subject.dump_value(value))
        expect do |b|
          subject.fetch_range(datetime_from, datetime_to, &b)
        end.to_not yield_control
      end
    end
  end
end
