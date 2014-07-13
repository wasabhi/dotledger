require 'timeseries_cache'

class BalanceCalculator
  attr_reader :account, :date_from, :date_to, :cache

  def initialize(options)
    @account = options.fetch(:account)
    @date_from = options.fetch(:date_from)
    @date_to = options.fetch(:date_to)
    @cache = TimeseriesCache.new(key: "account_balance:#{account.id}", ttl: 1.day)
  end

  def closing_balance
    account.balance - account.transactions.where(['posted_at > ?', date_to]).sum(:amount)
  end

  def balances
    cache.fetch_range(date_from, date_to) do |date|
      Balance.new(date: date, balance: balance_for(date), account_id: account.id)
    end
  end

  def as_json(options = {})
    ActiveModel::ArraySerializer.new balances, options
  end

  private

  def balance_for(date)
    closing_balance - subsequent_transaction_total(date)
  end

  def subsequent_transaction_total(date)
    account.transactions.where(posted_at: date..date_to).sum(:amount)
  end
end
