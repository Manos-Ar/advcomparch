#ifndef BRANCH_PREDICTOR_H
#define BRANCH_PREDICTOR_H

#include <sstream> // std::ostringstream
#include <cmath>   // pow()
#include <cstring> // memset()
#include <vector>
#include <deque>
#include <utility>

/**
 * A generic BranchPredictor base class.
 * All predictors can be subclasses with overloaded predict() and update()
 * methods.
 **/
class BranchPredictor
{
	public:
		BranchPredictor() : correct_predictions(0), incorrect_predictions(0) {};
		virtual ~BranchPredictor() {};

		virtual bool predict(ADDRINT ip, ADDRINT target) = 0;
		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) = 0;
		virtual string getName() = 0;

		UINT64 getNumCorrectPredictions() { return correct_predictions; }
		UINT64 getNumIncorrectPredictions() { return incorrect_predictions; }

		void resetCounters() { correct_predictions = incorrect_predictions = 0; };

	protected:
		void updateCounters(bool predicted, bool actual) {
			if (predicted == actual)
				correct_predictions++;
			else
				incorrect_predictions++;
		};

	private:
		UINT64 correct_predictions;
		UINT64 incorrect_predictions;
};

class FSMPredictor : public BranchPredictor{
	public :
		FSMPredictor(unsigned index_bits_)
			: BranchPredictor(), index_bits(index_bits_) {
				table_entries = 1 << index_bits;
				TABLE = new unsigned short [table_entries];
				memset(TABLE, 0, table_entries * sizeof(*TABLE));

			};

		~FSMPredictor() { delete[] TABLE; };

		virtual bool predict(ADDRINT ip, ADDRINT target) {
			unsigned int ip_table_index = ip % table_entries;
			unsigned short ip_table_value = TABLE[ip_table_index];
			if (ip_table_value >= 2) return true;
			else return false;
		};

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
			unsigned int ip_table_index = ip % table_entries;
			if (actual) {
				if (TABLE[ip_table_index] == 2)
					TABLE[ip_table_index] = 3;
				else if (TABLE[ip_table_index] == 1)
					TABLE[ip_table_index] = 3;
				else if (TABLE[ip_table_index] == 0)
					TABLE[ip_table_index] = 1;
			}
			else {
				if (TABLE[ip_table_index] == 3)
					TABLE[ip_table_index] = 2;
				else if (TABLE[ip_table_index] == 2)
					TABLE[ip_table_index] = 0;
				else if (TABLE[ip_table_index] == 1)
					TABLE[ip_table_index] = 0;
			}
			updateCounters(predicted, actual);
		};

		virtual string getName() {
			std::ostringstream stream;
			stream << "FSM-" << pow(2.0,double(index_bits)) / 1024.0 << "K";
			return stream.str();
		}

	private :
		unsigned int index_bits;

		//  Make this unsigned long long so as to support big numbers of cntr_bits.
		unsigned short *TABLE;
		unsigned int table_entries;
};

class NbitPredictor : public BranchPredictor
{
	public:
		NbitPredictor(unsigned index_bits_, unsigned cntr_bits_)
			: BranchPredictor(), index_bits(index_bits_), cntr_bits(cntr_bits_) {
				table_entries = 1 << index_bits;
				TABLE = new unsigned long long[table_entries];
				memset(TABLE, 0, table_entries * sizeof(*TABLE));

				COUNTER_MAX = (1 << cntr_bits) - 1;
			};
		~NbitPredictor() { delete TABLE; };

		virtual bool predict(ADDRINT ip, ADDRINT target) {
			unsigned int ip_table_index = ip % table_entries;
			unsigned long long ip_table_value = TABLE[ip_table_index];
			unsigned long long prediction = ip_table_value >> (cntr_bits - 1);
			return (prediction != 0);
		};

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
			unsigned int ip_table_index = ip % table_entries;
			if (actual) {
				if (TABLE[ip_table_index] < COUNTER_MAX)
					TABLE[ip_table_index]++;
			} else {
				if (TABLE[ip_table_index] > 0)
					TABLE[ip_table_index]--;
			}

			updateCounters(predicted, actual);
		};

		virtual string getName() {
			std::ostringstream stream;
			stream << "Nbit-" << pow(2.0,double(index_bits)) / 1024.0 << "K-" << cntr_bits;
			return stream.str();
		}

	private:
		unsigned int index_bits, cntr_bits;
		unsigned int COUNTER_MAX;

		/* Make this unsigned long long so as to support big numbers of cntr_bits. */
		unsigned long long *TABLE;
		unsigned int table_entries;
};

// Fill in the BTB implementation ...
class BTBPredictor : public BranchPredictor
{
	public:
		BTBPredictor(int btb_entries, int btb_assoc)
			: table_entries(btb_entries), table_assoc(btb_assoc), table_sets(btb_entries/btb_assoc), table(btb_entries/btb_assoc)
		{
			/* ... fill me ... */
		}

		~BTBPredictor() {
			/* ... fill me ... */
		}

		virtual bool predict(ADDRINT ip, ADDRINT target) {
			/* ... fill me ... */
			if (find(ip) != nullptr) return true;
			return false;
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
			/* ... fill me ... */
			std::pair<ADDRINT, ADDRINT>* tuple = find(ip);
			if (actual) {
				if (predicted && target == tuple->second) correctTargetPredictions++;
				else if (predicted) tuple->second = target;
				else add(ip, target);
			}
			else {
				if (predicted) remove(ip);
				else correctTargetPredictions++;
			}
			updateCounters(predicted, actual);
		}

		virtual string getName() {
			std::ostringstream stream;
			stream << "BTB-" << table_entries << "-" << table_assoc;
			return stream.str();
		}

		UINT64 getNumCorrectTargetPredictions() {
			/* ... fill me ... */
			return correctTargetPredictions;
		}

	private:
		int table_entries, table_assoc, table_sets;
		unsigned long long int correctTargetPredictions=0;
		std::vector<std::deque<std::pair<ADDRINT, ADDRINT>>> table;

		std::pair<ADDRINT, ADDRINT>* find(ADDRINT ip){
			unsigned row = ip % table_sets;
			std::deque<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			size_t size = q.size();
			for (size_t i=0; i<size; ++i){
				if (q[i].first == ip) return &q[i];
			}
			return nullptr;
		}

		void add(ADDRINT ip, ADDRINT target){
			unsigned row = ip % table_sets;
			std::deque<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			if (q.size() == (unsigned) table_assoc) q.pop_front();
			q.push_back(make_pair(ip, target));
		}

		void remove(ADDRINT ip){
			unsigned row = ip % table_sets;
			std::deque<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			for (auto it = q.begin(); it!=q.end(); it++){
				if ((*it).first == ip) {
					q.erase(it, it+1);
					break;
				}
			}
		}
};

class AlwaysTakenPredictor : public BranchPredictor {
	public:
		AlwaysTakenPredictor() {}
		~AlwaysTakenPredictor() {}

		virtual bool predict(ADDRINT ip, ADDRINT target){
			return true;
		}
		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target){
			updateCounters(predicted, actual);
		}

		virtual string getName(){
			return "AlwaysTaken";
		}
};

class BTFNTPredictor : public BranchPredictor {
	public:
		BTFNTPredictor() {}
		~BTFNTPredictor() {}

		virtual bool predict(ADDRINT ip, ADDRINT target){
			if (target < ip) return true;
			else return false;
		}
		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target){
			updateCounters(predicted, actual);
		}

		virtual string getName(){
			return "BTFNT";
		}
};

class LocalHistoryTwoLevelPredictor : public BranchPredictor {
	public:
		LocalHistoryTwoLevelPredictor(unsigned PHTentries, unsigned char PHTcntrlen, unsigned BHTentries, unsigned char BHTentrylen) :
			pht_entries(PHTentries), nr_bits(PHTcntrlen), bht_entries(BHTentries), bht_entry_len(BHTentrylen), PHT(PHTentries, NbitCounter(nr_bits)){
				BHT = new unsigned [bht_entries];
				memset(BHT, 0, bht_entries * sizeof(*BHT));
				bht_mask = (1 << bht_entry_len) - 1;
			}

		~LocalHistoryTwoLevelPredictor(){
			delete[] BHT;
		}

		virtual bool predict(ADDRINT ip, ADDRINT target){
			unsigned bht_index = ip % bht_entries;
			unsigned suffix = BHT[bht_index], prefix = (ip << bht_entry_len) % pht_entries;
			unsigned pht_index = prefix | suffix;

			return PHT[pht_index].predict();
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target){
			unsigned bht_index = ip % bht_entries;
			unsigned suffix = BHT[bht_index], prefix = (ip << bht_entry_len) % pht_entries;
			unsigned pht_index = prefix | suffix;

			BHT[bht_index] <<= 1;
			BHT[bht_index] |= actual;
			BHT[bht_index] &= bht_mask;

			PHT[pht_index].update(actual);

			updateCounters(predicted, actual);
		}

		virtual string getName(){
			std::ostringstream stream;
			stream << "LocalTwoLevel-" << pht_entries / 1024 << "K-" << (unsigned) nr_bits << "-" << bht_entries/1024 << "K-" << (unsigned) bht_entry_len;
			return stream.str();
		}

	protected:
		unsigned pht_entries;
		unsigned char nr_bits;

	private:
		class NbitCounter{
			public:
				NbitCounter(unsigned char cntr_bits) : n(cntr_bits) {
					COUNTER_MAX = (1<<n) - 1;
					count = 0;
				}

				bool predict(){
					return (count >> (n-1)) != 0;
				}

				void update(bool last){
					if (last){
						if (count < COUNTER_MAX) ++count;
					}
					else{
						if (count > 0) --count;
					}
				}

			private:
				unsigned char n;
				unsigned COUNTER_MAX, count;
		};
		unsigned bht_entries, bht_mask;
		unsigned char bht_entry_len;
		unsigned *BHT;
		std::vector<NbitCounter> PHT;
};

class GlobalHistoryTwoLevelPredictor : public LocalHistoryTwoLevelPredictor{
	public:
		GlobalHistoryTwoLevelPredictor(unsigned PHTentries, unsigned char PHTcntrlen, unsigned char BHRlen) :
			LocalHistoryTwoLevelPredictor(PHTentries, PHTcntrlen, 1, BHRlen), bhr_len(BHRlen) {}

		virtual string getName(){
			std::ostringstream stream;
			stream << "GlobalTwoLevel-" << pht_entries / 1024 << "K-" << (unsigned) nr_bits << "-" << (unsigned) bhr_len;
			return stream.str();
		}

	private:
		unsigned char bhr_len;
};

class TournamentPredictor : public BranchPredictor{
	public:
		TournamentPredictor(unsigned metaEntries, BranchPredictor* b1, BranchPredictor* b2) :
			meta_entries(metaEntries), pred1(b1), pred2(b2) {
				TABLE = new uint8_t [metaEntries];
				memset(TABLE, 0, meta_entries * sizeof(*TABLE));
			}

		~TournamentPredictor() override{
			delete[] TABLE;
			delete pred1;
			delete pred2;
		}

		virtual bool predict(ADDRINT ip, ADDRINT target){
			unsigned index = ip % meta_entries;
			if (TABLE[index] < 2) return pred1->predict(ip, target);
			else return pred2->predict(ip, target);
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target){
			bool first, second;
			unsigned index = ip % meta_entries;
			uint8_t value = TABLE[index];

			if (value < 2){
				first = predicted == actual;
				second = pred2->predict(ip, target) == actual;
			}
			else {
				first = pred1->predict(ip, target) == actual;
				second = predicted == actual;
			}
			if (first < second && value < 3) ++TABLE[index];
			else if (first > second && value > 0) --TABLE[index];

			pred1->update(predicted, actual, ip, target);
			pred2->update(predicted, actual, ip, target);

			updateCounters(predicted, actual);
		}

		virtual string getName() = 0;

	private:
		unsigned meta_entries;
		uint8_t *TABLE;
		BranchPredictor *pred1, *pred2;
};

class Alpha21264Predictor : public BranchPredictor{
	public:
		Alpha21264Predictor() : bhr(0), local(1024, 3, 1024, 10), global(4096, 2, 12) {
			bhr_mask = (1 << 12) - 1;
			TABLE = new uint8_t [4096];
			memset(TABLE, 0, 4096);
		}

		~Alpha21264Predictor() {}

		virtual bool predict(ADDRINT ip, ADDRINT target){
			if (TABLE[bhr] < 2) return local.predict(ip, target);
			else return global.predict(ip, target);
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target){
			bool first, second;
			uint8_t value = TABLE[bhr];

			if (value < 2){
				first = predicted == actual;
				second = global.predict(ip, target) == actual;
			}
			else {
				first = local.predict(ip, target) == actual;
				second = predicted == actual;
			}

			if (first < second && value < 3) ++TABLE[bhr];
			else if (first > second && value > 0) --TABLE[bhr];

			local.update(predicted, actual, ip, target);
			global.update(predicted, actual, ip, target);

			bhr = ((bhr << 1) | actual) & bhr_mask;

			updateCounters(predicted, actual);
		}

		virtual string getName() {
			return "Alpha 21264";
		}

	private:
		unsigned short bhr, bhr_mask;
		uint8_t *TABLE;
		LocalHistoryTwoLevelPredictor local;
		GlobalHistoryTwoLevelPredictor global;
};

class Tournament1Predictor : public TournamentPredictor {
	public:
		Tournament1Predictor() : TournamentPredictor(1024, new NbitPredictor(13, 2), new GlobalHistoryTwoLevelPredictor(8192, 2, 4)) {}

		string getName() override{
			return "2Nbit_vs_Global";
		}
};

class Tournament2Predictor : public TournamentPredictor {
	public:
		Tournament2Predictor() : TournamentPredictor(1024, new LocalHistoryTwoLevelPredictor(4096, 2, 2048, 4), new GlobalHistoryTwoLevelPredictor(4096, 4, 6)) {}

		string getName() override{
			return "Local_vs_Global";
		}

};

class Tournament3Predictor : public TournamentPredictor {
	public:
		Tournament3Predictor() : TournamentPredictor(2048, new NbitPredictor(12, 4), new LocalHistoryTwoLevelPredictor(6144, 2, 2048, 2)) {}

		string getName() override{
			return "4Nbit_vs_Local";
		}

};

class Tournament4Predictor : public TournamentPredictor {
	public:
		Tournament4Predictor() : TournamentPredictor(2048, new NbitPredictor(13, 2), new NbitPredictor(12, 4)){}

		string getName() override{
			return "2Nbit_vs_4Nbit";
		}

};

#endif
