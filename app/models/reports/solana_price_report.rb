module Reports
  class SolanaPriceReport < Report
    SOURCES = %w[FTX CoinGecko]

    def initialize(attrs)
      @name = 'SolanaPriceReport'

      super(attrs)
    end

    def self.all
      where(name: 'SolanaPriceReport')
    end
  end
end
