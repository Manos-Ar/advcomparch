#ifndef BRANCH_PREDICTOR_H
#define BRANCH_PREDICTOR_H

#include <sstream> // std::ostringstream
#include <cmath>   // pow()
#include <cstring> // memset()
#include <vector>
#include <deque>
#include <utility>
#include <cstdint>

/**
 * A generic BranchPredictor base class.
 * All predictors can be subclasses with overloaded predict() and update()
 * methods.
 **/
class BranchPredictor
{
	public:
		BranchPredictor() : correct_predictions(0), incorrect_predictions(0) {};
		~BranchPredictor() {};

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

		~FSMPredictor() { delete TABLE; };

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
				TABLE = new unsigned int long long [table_entries];
				memset(TABLE, 0, table_entries * sizeof(*TABLE));

				COUNTER_MAX = (1 << cntr_bits) - 1;
			};
		~NbitPredictor() { delete TABLE; };

		virtual bool predict(ADDRINT ip, ADDRINT target) {
			unsigned int ip_table_index = ip % table_entries;
			unsigned int long long ip_table_value = TABLE[ip_table_index];
			unsigned int long long prediction = ip_table_value >> (cntr_bits - 1);
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
		unsigned int long long *TABLE;
		unsigned int table_entries;
};

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
				if (predicted && target == tuple->second) {
					update_lru(ip);
					correctTargetPredictions++;
				}
				else if (predicted) {
					update_lru(ip);
					tuple->second = target;
				}
				else insert(ip, target);
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
		std::vector<std::list<std::pair<ADDRINT, ADDRINT>>> table;

		std::pair<ADDRINT, ADDRINT>* find(ADDRINT ip){
			unsigned row = ip % table_sets;
			std::list<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			std::list<std::pair<ADDRINT, ADDRINT>>::iterator itir;

			for (itir = q.begin(); itir!=q.end(); ++itir){
				if (itir->first == ip) return &(*itir);
			}
			return nullptr;
		}

		void update_lru(ADDRINT ip){
			unsigned row = ip % table_sets;
			std::list<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			std::list<std::pair<ADDRINT, ADDRINT>>::iterator itir;

			for (itir = q.begin(); itir!=q.end(); ++itir){
				if (itir->first == ip){
					std::pair<ADDRINT, ADDRINT> tuple = *itir;
					q.erase(itir);
					q.push_back(tuple);
					break;
				}
			}
		}
		void insert(ADDRINT ip, ADDRINT target){
			unsigned row = ip % table_sets;
			std::list<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			std::pair<ADDRINT, ADDRINT> tuple(ip,target);

			if(q.size()!= (unsigned) table_assoc) q.push_back(tuple);
			else {
				q.pop_front();
				q.push_back(tuple);
			}
		}

		void remove(ADDRINT ip){
			unsigned row = ip % table_sets;
			std::list<std::pair<ADDRINT, ADDRINT>>& q = table[row];
			std::list<std::pair<ADDRINT, ADDRINT>>::iterator itir;


			for (itir = q.begin(); itir!=q.end(); ++itir){
				if (itir->first == ip){
					q.erase(itir);
					break;
				}
			}
		}
};

class StaticATPredictor: public BranchPredictor{
	public:
		StaticATPredictor(){}
		virtual bool predict(ADDRINT ip, ADDRINT target){
			return true;
		}
		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
			updateCounters(predicted,actual);
		}
		virtual string getName() {
			std::ostringstream stream;
			stream << "StaticATPredictor" ;
			return stream.str();
		}
};

class StaticBTFNT: public BranchPredictor{
	public:
		StaticBTFNT(){}
		virtual bool predict(ADDRINT ip, ADDRINT target){
			if(target < ip) return true;
			else return false;
		}
		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
			updateCounters(predicted,actual);
		}
		virtual string getName() {
			std::ostringstream stream;
			stream << "StaticBTFNT" ;
			return stream.str();
		}
};

class LocalTwoLevel: public BranchPredictor{
	public:
		LocalTwoLevel(int p_entries, int b_entries, int b_length) : pht_entries(p_entries), bht_entries(b_entries), bht_length(b_length)
		{
			int predictors_perline = 1 << bht_length;
			pht = std::vector<std::vector<NbitCounter>>(pht_entries,std::vector<NbitCounter>(predictors_perline,NbitCounter(2)));
			bht = new uint8_t[bht_entries];
			memset(bht,0,bht_entries*sizeof(*bht));
		}

		~LocalTwoLevel(){
			delete[] bht;
		}

		virtual bool predict(ADDRINT ip, ADDRINT target)
		{
			int bht_index = ip % bht_entries, pht_index = ip % pht_entries, index_predictor;
			index_predictor = bht[bht_index];
			return pht[pht_index][index_predictor].predict();
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target)
		{
			int bht_index = ip % bht_entries, pht_index = ip % pht_entries, index_predictor;
			index_predictor = bht[bht_index];
			shift_register(bht_index, actual);
			pht[pht_index][index_predictor].update(actual);
			updateCounters(predicted,actual);
		}

		virtual string getName()
		{
			std::ostringstream stream;
			stream << "LocalTwoLevel-"<<bht_entries<<"-"<<bht_length ;
			return stream.str();
		}

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

		uint8_t *bht;
		int pht_entries, bht_entries, bht_length;
		std::vector<std::vector<NbitCounter>> pht;

		void shift_register (int bht_index, bool actual){
			bht[bht_index] = bht[bht_index] << 1;
			bht[bht_index] |= actual;
			if(bht_length == 4) bht[bht_index] &= 0x0f;
		}
};

class GlobalTwoLevel: public BranchPredictor{
	public:
		GlobalTwoLevel(int p_entries, int b_length, int nbits) : pht_entries(p_entries), bhr_length(b_length), bits(nbits)
		{
			int predictors_perline = 1 << bhr_length;
			bhr = 0;
			pht = std::vector<std::vector<NbitCounter>>(pht_entries,std::vector<NbitCounter>(predictors_perline,NbitCounter(bits)));
		}

		~GlobalTwoLevel(){
		}

		virtual bool predict(ADDRINT ip, ADDRINT target)
		{
			int pht_index = ip % pht_entries;
			return pht[pht_index][bhr].predict();
		}

		virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target)
		{
			int pht_index = ip % pht_entries;
			pht[pht_index][bhr].update(actual);
			shift_register(actual);
			updateCounters(predicted,actual);
		}

		virtual string getName()
		{
			std::ostringstream stream;
			stream << "GlobalTwoLevel-"<<bits<<"-"<<bhr_length ;
			return stream.str();
		}

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

		uint16_t bhr;
		int pht_entries, bhr_length, bits;
		std::vector<std::vector<NbitCounter>> pht;

		void shift_register (bool actual){
			bhr = bhr << 1;
			bhr |= actual;
			if(bhr_length == 5) bhr &= 0x001f;
			else bhr &= 0x03ff;
		}
};


#endif
