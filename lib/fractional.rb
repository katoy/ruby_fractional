# coding: utf-8

class Fractional
  attr_reader :sign, :fix_num, :repeat_num
  attr_reader :rational

  def initialize(a = 0, b = nil)
    case a
    when Rational
      fail 'bad initialize value.' if b != nil
      @rational = a
      (@sign, @fix_num, @repeat_num) = Fractional.get_repeat_nums(a.numerator, a.denominator)
    when String
      fail 'bad initialize value.' if b != nil
      f = Fractional.parse(a)
      @rational = f.rational
      (@sign, @fix_num, @repeat_num) = [f.sign, f.fix_num, f.repeat_num]
    when Fixnum
      b = 1 if b == nil
      fail 'bad initialize value.' unless b.is_a?(Fixnum)
      @rational = Rational(a, b)
      (@sign, @fix_num, @repeat_num) = Fractional.get_repeat_nums(a, b)
    else
      fail 'bad initialize value.'
    end
  end

  def self.parse(str)
    (sign, fix_num, repeat_num) = [1, [], []]
    fail 'Bad String'  if str == nil || str.length == 0
    if str[0] == '-' || str[0] == '+'
      sign = (str[0] == '+') ? 1 : -1
      str = str[1..-1]
    end

    fail 'Bad String' if str == nil || str.length == 0
    token = nil
    if str.index('.') == nil
      token = str.match /\A(\d*)\z/
      fail 'Bad String' if token == nil
    elsif str.index('{')
      token = str.match /\A(\d*)\.(\d*)\{(\d*)\}\z/
      fail 'Bad String' if token == nil
    else
      token = str.match /\A(\d*)\.(\d*)\z/
      fail 'Bad String' if token == nil
    end

    fix_num = [token[1].to_i]
    fix_num += token[2].split('').collect {|item| item.to_i }  if token[2] != nil
    repeat_num = token[3].split('').collect {|item| item.to_i } if token[3] != nil

    f_part = (token[2] != nil) ?
               f_part = Rational(sign * fix_num.join.to_i, (10 ** token[2].length))
             : f_part = Rational(sign * fix_num.join.to_i, 1)
    r_part = (repeat_num.length > 0) ?
               Rational(repeat_num.join.to_i, (10 ** (repeat_num.length) - 1) * (10 ** (fix_num.length - 1)))
             : Rational(0, 1)
    r = f_part + r_part
    Fractional.new(r.numerator, r.denominator)
  end

  #def to_rational
  #  @rational
  #end

  def to_s
    s = (sign == -1) ? '-' : ''
    ret = "#{s}#{@fix_num[0]}"

    s0 = (@fix_num.size > 1) ?    "#{@fix_num[1..-1].join}" : ''
    s1 = (@repeat_num.size > 0) ? "{#{@repeat_num.join}}"   : ''

    if s1.length > 0
      ret += ".#{s0}#{s1}"
    elsif s0.length > 0
      ret += ".#{s0}"
    end
    ret
  end

  private

  # a / b の小数表現を得る。
  #  配列 [符号、巡廻しない部分, 巡廻する部分] を返す。
  #  例：
  #    1/3 => [1, [1], [3]]
  #    1/7 -> [1, [0], [1, 4, 2, 8, 5, 7]]
  def self.get_repeat_nums(a, b)
    s = []  # 商を保存
    m = []  # 余りを保存
    sign = (1.0 * a / b > 0) ? 1 : -1
    (a, b) = [a.abs, b.abs]

    (r, a) = [a / b, a % b]
    s << r

    i = nil
    while a > 0
      m << a
      a = a * 10

      (r, a) = [a / b, a % b]
      s << r
      i = m.index(a)
      break if i != nil # 余りが繰り返されたので
    end

    (i == nil) ?
      [sign, s, []]
    : [sign, s[0..i], s[(i + 1)..-1]]
  end
end
