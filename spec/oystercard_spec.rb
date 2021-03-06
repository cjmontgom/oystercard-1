# frozen_string_literal: true

require 'oystercard'

describe Oystercard do
  let(:entry_station) { double :station }
  let(:exit_station) { double :station }
  let(:journey) { { entry: entry_station, exit: exit_station } }

  describe 'defaults' do
    it 'should have a balance of zero' do
      expect(subject.balance).to eq(0)
    end

  end

  describe '#top_up' do
    it 'should allow the user to top up their oystercard' do
      subject.top_up(5)
      expect(subject.balance).to eq(5)
    end

    it 'should not allow user to top up if the end balance is > Max balance' do
      msg = "Max balance £#{Oystercard::MAX_BALANCE} will be exceeded"
      subject.top_up(87)
      expect { subject.top_up(5) }.to raise_error msg
    end
  end

  describe '#touch_in' do
    it "should update a card as 'in use' when touching in" do
      subject.top_up(5)
      subject.touch_in(entry_station)
      expect(subject.in_journey?).to eq true
    end

    it 'should raise an error if touching in without the minimum balance' do
      msg = 'Cannot touch in: Not enough funds'
      expect { subject.touch_in(entry_station) }.to raise_error msg
    end
  end

  describe '#touch_out' do
    it "should update a card as 'not in use' when touching out" do
      subject.touch_out(exit_station)
      expect(subject.in_journey?).to eq false
    end

    it 'should set the entry station to nil' do
      subject.top_up(5)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject.journey.current[:entry]).to eq nil
    end

    it 'should deduct the fare from the card' do
      subject.top_up(5)
      subject.touch_in(entry_station)
      expect { subject.touch_out(exit_station) }.to change { subject.balance }.by(-1)
    end
  end


end
