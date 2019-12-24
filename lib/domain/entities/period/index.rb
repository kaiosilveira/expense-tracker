class Period
  attr_reader :month
  attr_reader :year

  def initialize(month, year)
    @month = month
    @year = year
  end
end
