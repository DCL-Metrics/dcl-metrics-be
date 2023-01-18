require './spec/spec_helper'

class KpisSpec < BaseSpec
  subject { Adapters::Dcl::DaoTransparency::KPIs.call(data: data) }

  let(:data) { parse_csv_fixture('dao_transparency/kpis.csv') }
  let(:expected_result) do
    {
      active_members: 4597,
      total_vp: 65_084_630,
      total_votes: 52691,
      proposals: {
        total: 1511,
        active: 12,
        active_percent: 0.79,
        enacted: 394,
        enacted_percent: 26.08,
        finished: 3,
        finished_percent: 0.2,
        passed: 167,
        passed_percent: 11.05,
        rejected: 935,
        rejected_percent: 61.88,
      },
      vp_sources: {
        mana: {
          members: 3328,
          amount: 34_888_272,
          percent: 53.6,
        },
        land: {
          members: 605,
          amount: 11_260_000,
          percent: 17.3,
        },
        names: {
          members: 1708,
          amount:1_289_900,
          percent: 1.98
        },
        delegated: {
          members: 83,
          amount: 17_646_458,
          percent: 27.11
        }
      },
      vp_distribution: {
        whales: {
          minimum_vp: 1_000_000,
          members: 12,
          percent: 0.26,
          percent_of_total_vp: 64.34
        },
        sharks: {
          minimum_vp: 100_000,
          members: 46,
          percent: 1,
          percent_of_total_vp: 24.34
        },
        dolphins: {
          minimum_vp: 10_000,
          members: 163,
          percent: 3.55,
          percent_of_total_vp: 7.22
        },
        fish: {
          minimum_vp: 1_000,
          members: 729,
          percent: 15.86,
          percent_of_total_vp: 3.54
        },
        crabs: {
          minimum_vp: 1,
          members: 3647,
          percent: 79.33,
          percent_of_total_vp: 0.56
        }
      }
    }
  end

  it 'returns the data in an expected format' do
    assert_equal(expected_result, subject)
  end
end
