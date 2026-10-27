# spec/fizz_buzz_spec.rb
RSpec.describe FizzBuzz do
  describe '.call' do
    it 'returns Fizz for 9' do
      expect(FizzBuzz.call(9)).to eq('Fizz')
    end
  end
end

# lib/fizz_buzz.rb
module FizzBuzz
  def self.call(n) = (n % 3).zero? ? 'Fizz' : n.to_s
end
