# encoding: utf-8

require 'spec_helper'

describe HasInterfaces do

  it "should set all the expected methods" do
    subject.test_methods.all? { |meth| subject.respond_to? meth }.should be_true
  end

  it "should allow extending class to use Forwardable mechanics" do
    subject.class.respond_to?(:def_delegators).should be_true
    subject.respond_to?(:plopinou).should be_true
  end

  it "should setup safe delegations" do
    subject.to_string.should be_nil
    subject.day.should be_nil
    subject.month.should be_nil
    subject.year.should be_nil

    subject.bim = DateTime.new(2001, 2, 3, 4, 5, 6)

    subject.to_string.should == "2001-02-03T04:05:06+00:00"
    subject.day.should == 3
    subject.month.should == 2
    subject.year.should == 2001
  end

  it "should set @dumpty as a Pathname" do
    # this should pass ! Make it pass !
    # subject.dumpty=('ploup').should be_nil

    subject.dumpty_with('.').should be_an_instance_of Pathname
    subject.dumpty=(Pathname.new('.')).should be_an_instance_of Pathname
    subject.dumpty_with('ploup').should be_an_instance_of Pathname

    subject.dumpty.should be_an_instance_of Pathname
    subject.dumpty.should == Pathname.new('ploup')
    subject.dumpty.dirname.should == Pathname.new('.')
  end

  it "should only set up a reader accessor for @poopoo" do
     subject.respond_to?(:poopoo=).should be_false
     subject.poopoo.should == 'pidoo'
  end

  context "defaults" do
    it "shouldn't have default value" do
      subject.dumpty.should be_nil
    end

    it "should have default value" do
      subject.pilou_pilou.should == Pathname.new('pilou_pilou')
    end

    it "should have default value as specified in the dsl" do
      subject.blam.should be_an_instance_of DateTime
    end

    it "can have a Proc as default value" do
      subject.humpty.should == Pathname.new('Humpty/dumpty')
    end

    it "should not use the default value" do
      subject.send :instance_variable_set, "@pilou_pilou", false
      subject.pilou_pilou.should_not == Pathname.new('pilou_pilou')
      subject.pilou_pilou.should == false
    end
  end

  context "DateTime interfaces with parameters" do
    it "should set @foo as a DateTime" do
      subject.foo_with 2001, 2, 3, 4, 5, 6

      # this should pass ! Make it pass !
      # subject.foo=('plawp').should be_an_instance_of DateTime

      subject.foo.should be_an_instance_of DateTime
      subject.foo.should == DateTime.new(2001, 2, 3, 4, 5, 6)
    end

    it "should set @foo as a DateTime with DateTime instance" do
      subject.foo_with DateTime.new(2001, 2, 3, 4, 5, 6)
      # this should pass ! Make it pass !
      # subject.foo=('plawp').should be_an_instance_of DateTime

      subject.foo.should be_an_instance_of DateTime
      subject.foo.should == DateTime.new(2001, 2, 3, 4, 5, 6)
    end

    it "should set @bar as a DateTime with fitting bar_setter method" do
      subject.bar_with 2001, 2, 3, 4, 5, 6

      subject.bar.should be_an_instance_of DateTime
      subject.bar.should == DateTime.new(2000, 2, 3, 4, 5, 6)
    end
  end

end
