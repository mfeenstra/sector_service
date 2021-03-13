# app/services/sector_service.rb
#
# Copyright 2021
# Matt Feenstra
# All Rights Reserved.
#
# This is a data transformation from a dirty (PostgresDB) source that provides
#   an organized tree, like the the one below:
#
# @data = {  'sector1_name' => [ { 'industry1' => ['aapl', 'msft'] },
#                                { 'industryN' => ['abc', 'dddd']  } ],
#            'sector2_name' => [ { 'industryA' => ['qwe', 'erty']  },
#                                { 'industryB' => ['zzz', 'yyy']   } ]
#         }

SECTOR_MAP = "#{Rails.root}/config/sector_map.yml"
SECTOR_LOG = "#{Rails.root}/log/sector_service.log"
SECTOR_LOG_LEVEL = Logger::INFO

class SectorService
  attr_reader :data, :sectors, :industries, :symbols

  def initialize
    log 'Begin'
    @sectors = []
    @industries = []
    @symbols = []
    @data = {}
    statement = %(SELECT infos.sector, tickers.symbol, infos.industry
      FROM tickers INNER JOIN infos ON infos.ticker_id = tickers.id
      WHERE (industry <> '') IS NOT FALSE AND (sector <> '') IS NOT FALSE
      ORDER BY sector ASC).tr("\n", ' ').gsub(/\s+/, ' ')
    query = Ticker.connection.select_all(statement).to_a
    log "Number of results: #{query.size}\nTransforming data.."
    i = 0
    while i < query.size do
      sector = query[i]['sector'] || 'NA'
      @sectors.push(sector)
      symbol = query[i]['symbol'] || 'NA'
      @symbols.push(symbol)
      industry = query[i]['industry'].gsub(/w?\ $/,'') || 'NA'
      @industries.push(industry)
      # init sector
      if @data[sector].blank? then @data[sector] = [] end
      # get all the industries' hash keys from this sector
      mykeys = []
      @data[sector].each { |h| mykeys.push h.keys.first }
      # inititalize this industry if necessary and push the symbol
      unless mykeys.include? industry then 
        @data[sector].push( { industry => [symbol] } )
      else
        # find which array index this industry lives at
        industry_index = @data[sector].rindex { |ind| ind.keys.first == industry }
        # add this symbol
        @data[sector][industry_index][industry].push symbol
      end
      i += 1
    end
    @data
  end

  # create / update the config/sectors_map.yml
  def update
    if @data.empty? then
      msg = 'ERROR: SectorService.update ran with no @data!'
      puts msg
      log msg
      return
    end
    outfile = File.open(SECTOR_MAP, 'w')
    outfile.puts @data.to_yaml
    outfile.close
  end

  private

  def log(message)
    logger = Logger.new(SECTOR_LOG, 10, 1024000, datetime_format: '%Y-%m-%d %H:%M:%S')
    logger.level = SECTOR_LOG_LEVEL
    logger.info "\n#{eval DBUG}\n#{message}"
    logger.close
    message
  end

end
