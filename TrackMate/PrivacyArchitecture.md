# **TrackMate Privacy Architecture**
## Purpose
TrackMate is designed so that a linked relationship account cannot be used
 to monitor another user's private thoughts, journal entries, safety analysis, 
or personal behavioral insights.

The application separates private source data from shared relationship metadata.
## Private Data
The following information is private to the user who created it:
- Text in journal entries
- Interaction notes
- Personal reflections
- LLM sentiment and well-being analysis
- Personal growth insights
- Safety classifications
- Toxicity and safety scores
- Safety alerts
- Model prompts generated from private content
- Model reasoning or intermediate anaolysis derived from private content

Private data may be stored in the owners Cloud database when iCloud synchronization is enabled.
Private data is never copied into the shared iCloud database.
Linked users never have access to another user's private data listed above.

## Shared Data
Only explicitly approved data may be written to the shared store. The primary shared projection
entity will be SharedSnapshot. Shared data may include:
- Stable UUID identifiers
- Relationship idetifier
- Sanitized event identifier
- Approximate event timestamp
- Friction categroy 
- Sentiment band
- Interaction valence
- Schema version
- Mutual event-match state
- Explicitly approved privacy-filtered perspective summaries

Shared data will never contain journal entry text or the LLM's private safety analysis.

## Privacy Projection Rule
Private objects are never shared directly. Private information may only enter the shared store
through an explicit privacy-projection layer. The projection layer must construct a new shared
object using an allowlist of approved fields. No generic onject copying, serialization, 
reflection, or automatic sync from private entities into shared entities is permitted.

## Store Boundary
TrackMate will use separate Core Data persistent stores for private and shared iCloud data.
Private entities belong to the private store. Shared entities belong the shared store.
Core Data relationships must not cross persistent-store boundaries.
Entities in different stores must reference each other using stable UUID values instead of NSManagedOnject relationships.

## Journal Rule
Journal entries are always private. Raw text from a journal entry should never be:
- Stored in a SharedSnapshot
- Stored in a shared CloudKit record
- Sent to another linked user's device
- Included ijn Firebase Analytics
- Included in shared model prompts
- Used directly for mutual event comparison

## Local Analysis Rule
NaturalLanguage analysis and privacy-sensitive Foundation Models analysis must occur locally on the user's device. Private
source text may be analyzed locally to produce abstract metadata. Only explicitly approved abstract metadata may be
persisted into the shared store.

## Linked Account Rule
Linkign accounts does not grant either participant to acces to the other's private database. Account linking provides access only
to records that were intentionally written to the shared store. Either participant must be able to use TrackMate privately without 
exposing private journal or safety information to the linked participant.

## Mutual Analysis Rule
Mutual analysis must not requrie sharing raw journal text. Wehn comparison of two perspectives is requried, each device must first 
geerate a privacy-filtered PerspectiveSummary locally. Only the approved summary may be shared. Mutual analysis operates on 
those summaries or other approved shared metadata.

## Safety Rule
Safety and toxicity analysis is private. Safety scores, toxicity s ores, severe-pattern classifications, escellation state, and safety alerts 
must never appear in the shared store. The linked participant must not be informed that the other user's safety engine has triggered.

## Firebase Rule
Firebase must not receive relationship content, inlcuding:
- Journal text
- Interaction notes
- Perspective text
- Safety classifications
- Toxicity scores
- Personal insights
- Model prompts
- Model responses containing private relationship content

Firebase may be used only for approved non-content operational telemetry, including:
- Feature usage
- Analysis success or failure
- Model availability 
- Sync health
- Performance information
- Crash information

## Architectural Principle
Private data produces shared abstractions. Shared data never grants access back into private data.

