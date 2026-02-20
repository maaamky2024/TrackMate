//
//  RedFlagSeeder.swift
//  TrackMate
//
//  Created by Glen Mars on 4/12/25.
//

import Foundation
import CoreData
import SwiftUI

func preloadRedFlagsIfNeeded(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<RedFlags> = RedFlags.fetchRequest()
    fetchRequest.fetchLimit = 1

    do {
        let existing = try context.fetch(fetchRequest)
        if existing.isEmpty {
            print("\u{1F504} Preloading red flags...")

            let seedData: [(String, String, [String], [String], [String], [String])] = [
                (
                    "Gaslighting",
                    "Manipulating someone into questioning their own reality.",
                    ["You're too sensitive.", "That never happened.", "You're imagining things."],
                    ["Document conversations and events to maintain clarity.", "Talk to someone you trust about what happened."],
                    ["I remember it differently.", "I trust my own perception of events."],
                    ["https://www.verywellmind.com/signs-of-gaslighting-4147470"]
                ),
                (
                    "Love Bombing",
                    "Overwhelming someone with affection to gain control.",
                    ["You're the best thing that ever happened to me.", "I can't live without you."],
                    ["Set boundaries early on.", "Pay attention to whether affection feels authentic or manipulative."],
                    ["I appreciate your affection, but I need time to process.", "Let’s slow down and get to know each other better."],
                    ["https://psychcentral.com/blog/what-is-love-bombing"]
                ),
                (
                    "Stonewalling",
                    "Refusing to communicate or cooperate, often as a control tactic.",
                    ["Ignoring texts or calls during arguments.", "Walking away mid-conversation."],
                    ["Express your need for open communication.", "Don't chase—allow space but maintain your boundaries."],
                    ["We can take a break, but let’s revisit this soon.", "I need to have this conversation eventually for clarity."],
                    ["https://www.gottman.com/blog/the-four-horsemen-stonewalling/"]
                ),
                (
                    "DARVO",
                    "Deny, Attack, and Reverse Victim and Offender — a common manipulation tactic.",
                    ["You're attacking me!", "You're the one who hurt me."],
                    ["Stay calm and document the exchange.", "Seek validation from neutral third parties."],
                    ["Let’s focus on the original issue.", "This feels like you're turning the situation against me."],
                    ["https://www.healthline.com/health/darvo"]
                ),
                (
                    "Trauma Bonding",
                    "A strong emotional attachment to an abuser due to cycles of abuse and intermittent reinforcement.",
                    ["But they apologized after.", "They said it won't happen again."],
                    ["Educate yourself on trauma bonds.", "Create physical and emotional distance where possible."],
                    ["I deserve consistency and respect.", "My feelings are valid even if I care about them."],
                    ["https://psychcentral.com/lib/what-is-trauma-bonding"]
                ),
                (
                    "Hoovering",
                    "When an abuser tries to suck someone back into a toxic cycle by pretending to change.",
                    ["I’ve changed, I swear.", "I miss you, let’s talk just once."],
                    ["Block contact when possible.", "Remind yourself of past patterns."],
                    ["I’ve seen this before and I’m not going back.", "Closure doesn’t require reopening the wound."],
                    ["https://www.medicalnewstoday.com/articles/hoovering"]
                ),
                (
                    "Codependency",
                    "Excessive emotional or psychological reliance on a partner, often to the detriment of self.",
                    ["I can’t be happy unless you are.", "You need me to fix this for you."],
                    ["Develop personal boundaries.", "Learn to separate your emotions from others."],
                    ["I need to take care of myself too.", "My worth isn’t based on someone else’s needs."],
                    ["https://www.verywellmind.com/what-is-codependency-5072124"]
                ),
                (
                    "Control Disguised as Boundaries",
                    "Using the language of boundaries to actually control or isolate someone.",
                    ["I have a boundary that you can’t talk to your friends.", "My boundary is that you tell me everything."],
                    ["Clarify the difference between healthy boundaries and demands.", "Ask whether the boundary respects both parties."],
                    ["That doesn’t feel like a boundary, it feels like control.", "Let’s revisit what boundaries mean for each of us."],
                    ["https://www.psychologytoday.com/us/blog/the-right-mindset/202206/how-tell-if-boundary-is-real"]
                )
            ]

            for (category, description, examples, tips, scripts, resources) in seedData {
                let redFlag = RedFlags(context: context)
                redFlag.id = UUID()
                redFlag.category = category
                redFlag.redflagDescription = description
                redFlag.examples = examples as NSObject as? [String] as NSObject?
                redFlag.tips = tips as NSObject as? [String] as NSObject?
                redFlag.scripts = scripts as NSObject as? [String] as? NSObject
                redFlag.resources = resources as NSObject as? [String] as NSObject?
                redFlag.isFavorite = false
            }
            do {
                try context.save()
            } catch { print("\u{2705} Red flags seeded.") }
        } else {
            print("\u{2705} Red flags already exist.")
        }
    } catch {
        print("\u{274C} Failed to seed red flags: \(error.localizedDescription)")
    }
}

