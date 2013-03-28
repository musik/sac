#encoding: utf-8
require 'typhoeus'
require 'nokogiri'
require 'ostruct'
require 'chinese_cities'
require 'pp'
module Sac
  class << self
    def run
      @links = list
      @links.each do |id|
        pp item id
        break
      end
    end
    def list
      @links ||= begin
        response = Typhoeus::Request.get('http://cx.sac.net.cn/huiyuan/g/cn/cx/z.jsp?m_type=zqgs')  
        doc = Nokogiri::HTML(response.body.encode('UTF-8','GBK'))
        links = []
        doc.css('.deep a').each do |link|
          links << link.attr('href').match(/id\=(\d+)/)[1]
        end
        links.uniq
      end
    end
    def item id
      url = "http://cx.sac.net.cn/huiyuan/g/cn/cx/zqgs_home.jsp?id=#{id}"
      response = Typhoeus::Request.get(url)  
      doc = Nokogiri::HTML(response.body.encode('UTF-8','GBK'))
      data = {'oid' => id.to_i}
      c1 = doc.at_css('#content1')
      size = c1.css('td').size
      Range.new(0,size/2-1).each do |i|
        key = c1.css('td')[i*2].text.strip
        val = c1.css('td')[i*2+1].text.strip
        next if key !~ /[^[:space:]]/
        data[key] = val
      end
      Company.import data
    end
  end
  class Company < OpenStruct
      def initialize data={}
        super data
        convert_types
      end
      def convert_types

      end
     def self.import data
        keys = {
          :oid => 'oid',
          :name => '中文全称',
          :address => '办公地址',
          :address1 => '注册地',
          :contact => '法定代表人',
          :sn =>'经营证券业务许可证编号',
          :capital =>'注册资本',
          :postal =>'办公地址邮码',
          :email =>'公司电子邮箱',
          :phone =>'客户服务或投诉电话',
          :website =>'公司网址　',
          :scopes =>'已经获相关业务资格',

        }
        hash = {} 
        keys.each do |k,v|
          hash[k] = data[v]
        end
        self.new(hash)
     end
  end
end
