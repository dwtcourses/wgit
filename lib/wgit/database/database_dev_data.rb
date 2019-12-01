require 'securerandom'

module Wgit
  # Module containing example DB collection objects. The 'url' fields use a
  # UUID in order to be unique.
  #
  # Used in testing and development. This module isn't packaged in the gem and
  # is for devs (via the development console) and tests (setup and assertions)
  # only.
  module DatabaseDevData
    # Returns a Hash representing a Url record in the DB.
    def self.url(url: 'http://www.example.co.uk', timestamps: true)
      url.chop! if url.end_with?('/')

      hash = {
        'url' => "#{url}/#{SecureRandom.uuid.split('-').last}",
        'crawled' => true,
        'date_crawled' => '2016-04-20 14:33:16 +0100',
        'crawl_duration' => 0.6
      }

      if timestamps
        hash['date_added']    = '2016-04-20 14:33:16 +0100'
        hash['date_modified'] = '2016-04-20 14:35:00 +0100'
      end

      hash
    end

    # Returns a Hash representing a Document record in the DB.
    def self.doc
      {
        'url' => url(
          url: 'http://altitudejunkies.com/everest.html',
          timestamps: false
        ),
        'title' => 'Altitude Junkies | Everest',
        'base' => nil,
        'author' => 'LTE Designs',
        'keywords' => ['Everest', 'Highest Peak', 'High Altitude', 'Altitude Junkies'],
        'links' => [
          'index.html',
          'everest.html',
          'lhotse.html',
          'makalu.html',
          'dhaulagiri.html',
          'cholatse.html',
          'cordillerablanca.html',
          'leaders.html',
          'news.html',
          'everestroute.html',
          'everestnepalschedule.html',
          'http://www.summitoxygen.com',
          'http://www.globalrescue.com/altitudejunkies/',
          'geareverest.html',
          'dispatcheverest16.html',
          'dispatcheverest15.html',
          'dispatcheverest14.html',
          'dispatcheverest13.html',
          'dispatcheverest12.html',
          'dispatcheverest11.html',
          'dispatcheverest10.html',
          'dispatcheverest09.html',
          'dispatcheverest.html',
          'mailto:info@altitudejunkies.com',
          'http://www.mountainhouse.com',
          'http://www.brunton.com',
          'http://www.suunto.com',
          'http://www.mountainhardwear.com',
          'http://www.blackdiamondequipment.com',
          'http://www.salomon.com',
          'http://www.pelican.com',
          'http://www.julbousa.com',
          'http://www.cascadedesigns.com/msr'
        ],
        'text' => [
          'Route',
          'Dates',
          'TBA',
          'Price',
          'Included Extras',
          'Single Room Kathmandu',
          'Helicopter Flights',
          'Personal Climbing Sherpa',
          'Two Personal Sherpa on Summit Day',
          'Sherpa Summit Bonus',
          'Kitchen Staff Gratuities',
          'Leader',
          'Required Experience',
          'All climbers need to have climbed on a 7,000-8,000-meter peak previously',
          'Itinerary',
          'Days 1-2.     Kathmandu',
          'Days 3.         Helicopter to Namche Bazar',
          'Days 3-4.     Namche Bazar',
          'Days 5-10.   Trek to Base Camp',
          'Days 11-56.  Climbing',
          'Days 57.       Trek to Pheriche',
          'Days 58.       Helicopter to Kathmandu',
          'Days 59.       Kathmandu',
          'Days 60.       Depart Kathmandu',
          'Oxygen',
          'We provide six 4-Liter Poisk oxygen bottles, a',
          'mask and regulator set',
          'Sherpas',
          'We provide a 2:1 Sherpa to climber ratio. All our Sherpa climb above Camp 3 with oxygen',
          'Insurance',
          'Climbers are required to have evacuation and medical insurance and we recommend using',
          'More Information',
          'Everest, Nepal',
          'Altitude Junkies offer one of the most cost-effective full-service expeditions on Everest on the Nepalese side of the mountain.',
          "We don't advertise an expedition price and then ask for additional payments at the conclusion of the expedition such as Sherpa summit bonus and kitchen staff gratuities as some of the other operators do. The price you pay the Junkies is the final price.",
          ' ',
          'Difference from other Everest Expeditions',
          'There are several differences between Altitude Junkies and other Everest expeditions.',
          '· Small team size and large staff ratios for personalized service',
          '· Experienced leadership and Sherpa staff',
          '· Single room accommodation before and after expedition',
          '· Private helicopter flight to Lukla and from Pheriche',
          '· Personal climbing Sherpa at all times on the mountain',
          '· Two personal climbing Sherpa on summit day',
          '· Extra oxygen with maximum oxygen flow rate on summit day',
          '· Sherpa climb with oxygen at all times above 7,300 meters to conserve',
          '  stamina',
          '· Sherpa carry minimum loads during expedition due to large number of',
          '  support staff',
          '· Extra kitchen support staff with attention to service and food quality',
          '· Fresh meats, vegetables and fruits regularly flown in by helicopter',
          '· All Sherpa summit bonuses and kitchen staff gratuities included in',
          '  expedition price',
          '· Best value for money for services and staff provided',
          'Team Size',
          'Our expedition is limited to eight climbers and one expedition leader with a 2:1 Sherpa to climber ratio. Some of the other operators have as many as thirty climbers on one expedition and we feel a smaller team makes for a more intimate and satisfying experience for a climber on Everest.',
          'The single leader/expedition manager offers similar expertise as a fully guided climb with a 4:1 climber to guide ratio. Having a 2:1 climbing Sherpa to climber ratio allows each climber a flexible schedule to travel with their own personal Sherpa during acclimatization rotations and having two Sherpas with them on their summit day. Having a personal Sherpa to climb with each member means that climbers are assisted with the carrying of their personal loads if required, therefore reducing their pack weight considerably.',
          'Leadership',
          'Himalayan veteran expedition organizer Phil Crampton who has multiple Everest summits from both the Nepal and Tibet sides of the mountain will once again lead the 2016 expedition and this will be his thirteenth Everest expedition.',
          "In addition to an experienced leader, the team\u2019s head climbing Sherpa Sirdar will be Dorje Sherpa. Dorje was one of the Sherpas responsible for carrying the IMAX camera from the South Col to the Summit for the hugely successful IMAX Everest film from the 1996 spring season. Dorje has vast experience being a Sirdar on Everest, this being his twenty-first Everest expedition and will be directing our climbing Sherpas who have all summitted Everest before, some multiple times and their knowledge of the mountain is unrivaled.",
          'Helicopters to the Khumbu',
          'Our expedition will meet in the capital city of Nepal, Kathmandu where we will stay in the beautiful Hotel Tibet located in a quiet area of the diplomat district of Lazimpat.',
          'After a few days in Kathmandu getting to know our fellow team members we take private helicopters to Lukla, the gateway of the Khumbu and then onto Namche Bazar, the trading center of the Kumbu. The fixed wing flights from Kathmandu to Lukla are sporadic to say the least and are very weather dependent. Helicopters are a safer option and can fly when fixed wing aircraft are grounded. This is especially important at the conclusion of the expedition when the fixed wing flights can be grounded for up to a week due to unsuitable weather conditions at the airport.',
          'Helicopters from Base Camp',
          'We do not use helicopters for extraction from base camp as we feel this elevation is too dangerous for anything other than emergency flights. All members are requested to walk to Pheriche where we take private helicopters to Lukla. At Lukla we transfer to larger helicopters for the flight back to Kathmandu.',
          'The Trek to Base Camp',
          'After arriving at Lukla by helicopter we then shuttle the team to Namche Bazar. After acclimatizing for two days in Namche we will start the six day trek to base camp. Each evening we will stay in the best teahouse lodges on route and our kitchen staff will supervise all food preparation in the lodge kitchens. We will take cautious acclimatization rest days at Dingboche and at Loboche.',
          'Base Camp',
          'Our base camp is as luxurious, if not more so than some of the other more expensive operators and the food prepared by our highly experienced cooks is considered some of the best available in the Himalayas.',
          'Each climber is provided with a personal Mountain Hardwear 3-person tent at base camp, which is insulated with a foam floor covering and complimented with an extra thick foam mattress. Every tent has on demand lighting provided by solar electricity.',
          'For group occasions we provide double walled tents for dining and another as our communication tent. The dining tent has large padded chairs and is spacious, carpeted, heated and lit by solar electricity. Our communication tent has the same facilities as our dining dome but with the addition of multiple laptop computers and satellite internet modems and satellite phones.',
          'We provide a carpeted, heated and solar-lit toilet and shower tent with flushable toilets, stainless steel wash sinks and hot water on demand propane heated showers. We make it a policy at Altitude Junkies to remove all human waste from base camp and camp two respectively and have porters carry our toilet drums to a lower village where it can be disposed of properly.',
          'Advanced Base Camp (Camp Two)',
          'We keep an advanced base camp (camp two) established at an elevation of 6,400-meters with a full-time kitchen crew throughout the duration of the expedition. This is essential as even though we spend very little time there, our Sherpas spend many evenings here while they stock and supply the higher camps. It is not quite as luxurious as our base camp but will have a solar lit and heated double walled dining tent with tables and stools for dining and a toilet tent.',
          'The Kitchen',
          'The head and assistant cooks have all been trained by western chefs in food preparation and strict hygiene standards and produce a varied and nutritious western menu throughout the expedition. They prepare three delicious hot meals a day as well as preparing an amazing array of appetizers for our customary early evening cocktail hour during rest days at base camp. We use local fresh produce and meats and these are complimented by a huge selection of imported foods and snacks. Our cooks are especially proud of our immaculately clean kitchen, which is fully carpeted to reduce dust underfoot and has all stainless steel countertops for food preparation. The kitchen is complimented with propane barbeque grills and propane ovens they use to bake us all sorts of treats.',
          'Climb Strategy',
          "We follow a cautious acclimatization schedule at base camp spending several nights in residence before taking our first trip into the icefall to get familiar with it's terrain and practice crossing a few ladders before returning to base camp.",
          'We plan to only ascend through the icefall two times during the entire expedition including the summit push. When we have spent several days at base camp we make our first rotation on the mountain with a climb through the Khumbu Icefall to camp one at an elevation of 6,000-meters where we spend the evening.',
          'The following day we walk up the Western Cwm the short distance to camp two at an elevation of 6,400-meters. Here we spend several evenings to let our bodies adjust to the increased altitude.',
          'Once all the team members are feeling adjusted to the altitude we tag camp three at an elevation of 7,300-meters before descending to camp two. We spend another evening at this campsite before descending to base camp.',
          'After resting at base camp or dropping to a lower village for recovery we plan our summit attempt. When the summit weather window appears we move into position with a direct climb from base camp to camp two. We spend a rest day at this campsite before making the climb to camp three. The following day we make an early start for the climb to camp four at 7,950-meters. We aim to arrive early at camp four to allow for plenty of rest before departing later that evening for our summit push.',
          'After the summit is reached climbers will descend to camp four for the evening and the following day descend to camp two. We spend the night at camp two before making an early morning departure for our last time through the icefall heading towards base camp.',
          'All climbers and Sherpas will be using supplementary oxygen from camp three and return to camp two.',
          'Each climber is allocated six 4-liter bottles of oxygen for the climb. This allows a climber to use two liters per minute for the climb from camp three to camp four and four liters per minute for the climb from camp four to summit and return to camp four. Climbers will sleep on oxygen at camp four and will have a designated bottle with high flow rate for the descent from camp four to camp two.',
          'Each climbing Sherpa is allocated five 4-liter bottles as they use oxygen on all load carries above camp three. Allowing the Sherpas to climb at all times above 7,300-meters on oxygen ensures that they are stronger for the summit push which is safer for all the team members.',
          'High Altitude Camps',
          'Mountain Hardwear 3-person tents will be used at high camps and these will be occupied by two persons up to the high camp where we usually place three persons per tent for warmth. All food, stoves and cooking gas will be in place and members are only required to carry their personal gear during the expedition.',
          'Health',
          'All climbing members, climbing Sherpas and kitchen staff have unlimited access to doctors from the Himalayan Rescue Association who are stationed at base camp throughout the season. We have our own medical oxygen, portable altitude chambers and comprehensive medical chests at both base and advanced base camps. The higher camps also have medical kits and we also ask that all climbers carry individual micro high altitude medical kits at all times above base camp as the Sherpas and leader does. All climbing members and climbing Sherpas wear a personal avalanche beacon above base camp.',
          'Communications',
          'For constant communication we have all climbing members, climbing Sherpas and guides have their own personal two-way radio at all times on the mountain. We also have base station radios at both base and advanced base camp and have these active at all times when members and Sherpas are on the mountain.',
          'Our satellite phones and satellite internet modems are available for our team members to use at base camp at actual cost price as we feel charging an outrageous amount to phone or email family is unfair during such a long expedition.',
          'Weather Forecasts',
          'To ensure the safety of all our climbers we subscribe to a professional weather forecast service for the duration of the season and have access to this information at all the respective base and high camps and receive constant updates during our summit push.',
          'Guided versus Non-Guided Expeditions',
          '8,000-meter peaks are a serious undertaking and climbers need to be aware there are certain risks that are out of the control of Altitude Junkies. We prefer to describe our Everest expedition as professionally managed rather than guided. A true guided expedition is only where the guides have UIAGM certification, which is the only internationally recognized qualification for mountain guides and there is a 3:1 or smaller guide to climber ratio',
          'Climbers on our Everest expedition need to have previously climbed on a 7,000-meter or 8,000-meter Himalayan peak to qualify for our expedition. We do not consider a climb of Aconcagua by its normal route or false traverse as suitable experience to climb Everest with the Junkies.',
          'If you need to be guided, look for guides with full UIAGM certification.',
          'Altitude Junkies does not allow any solo climbing above base camp on any of our expeditions.',
          'Photo credits: Brad Jackson - Everest Southeast Ridge as seen from Camp Two.',
          '· Individual accommodation in Kathmandu as itinerary',
          '· Private helicopter from Kathmandu to Lukla',
          '· Private helicopter from Pheriche to Kathmandu',
          '· Shared accommodation on trek as itinerary',
          '· All meals on trek as itinerary',
          '· Porters for personal gear to base camp and return',
          '· All meals at base and advanced base camp',
          '· 2:1 climbing Sherpa to climber ratio',
          '· Group cooks at base and advanced base camp',
          '· Icefall fixed rope fee',
          '· Camp two to summit fixed rope fee',
          '· Expedition permit, peak fee and conservation fees',
          '· Base camp, advanced base camp and high camp tents',
          '· Group climbing equipment, stoves and fuel',
          '· Supplementary climbing oxygen (6 bottles), mask and regulator',
          '· Two-way radios',
          '· Medical kits, portable altitude chamber and medical oxygen',
          '· High altitude freeze-dried meals',
          '· Unlimited access to doctors from HRA at base camp',
          '· Climbing Sherpa summit bonus and carry bonus',
          '· Kitchen staff tips',
          '· Satellite phone and satellite internet use at cost price',
          '· Airfare to and from Nepal',
          '· Meals and drinks in Kathmandu',
          '· Alcoholic beverages',
          '· Nepal visa costs',
          '· Evacuation costs, medical and rescue insurance',
          '· Personal climbing clothing and equipment',
          '· Personal Puja contribution',
          '|',
          'Copyright © 2006-2016 Altitude Junkies. All Rights Reserved'
        ],
        'date_added' => '2016-04-20 14:33:16 +0100',
        'date_modified' => '2016-04-20 14:35:00 +0100'
      }
    end
  end
end
