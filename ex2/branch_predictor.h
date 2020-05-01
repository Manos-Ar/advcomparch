#ifndef BRANCH_PREDICTOR_H
#define BRANCH_PREDICTOR_H

#include <sstream> // std::ostringstream
#include <cmath>   // pow()
#include <cstring> // memset()
#include <algorithm>

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

 // private:
    UINT64 correct_predictions;
    UINT64 incorrect_predictions;
};

class FSM : public BranchPredictor{
	public :
    FSM(unsigned index_bits_, unsigned cntr_bits_)
        : BranchPredictor(), index_bits(index_bits_), cntr_bits(cntr_bits_) {
        table_entries = 1 << index_bits;
        TABLE = new unsigned int [table_entries];
        memset(TABLE, 0, table_entries * sizeof(*TABLE));

        COUNTER_MAX = (1 << cntr_bits) - 1;
    };

    ~FSM() { delete TABLE; };

    virtual bool predict(ADDRINT ip, ADDRINT target) {
      unsigned int ip_table_index = ip % table_entries;
      unsigned int ip_table_value = TABLE[ip_table_index];
			if(ip_table_value == 3 || ip_table_value == 2) return true;
/*			else if (ip_table_value == 2 || ip_table_value == 0) return false;*/
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
    stream << "FSM-" << pow(2.0,double(index_bits)) / 1024.0 << "K-" << cntr_bits;
    return stream.str();
    }

	private :
    unsigned int index_bits, cntr_bits;
    unsigned int COUNTER_MAX;

   //  Make this unsigned long long so as to support big numbers of cntr_bits.
    unsigned int *TABLE;
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

class Entry_info{
	public:
		int set_pos;
		ADDRINT branch_address, target_address;
		Entry_info() : set_pos(-1), branch_address(-1), target_address(-1){};
		void set(ADDRINT tar_address, ADDRINT br_address, int pos){
			target_address = tar_address;
			branch_address = br_address;
			set_pos = pos;
		}
		void reset(){
			branch_address = -1;
			target_address = -1;
			set_pos = -1;
		}
};

class BTBPredictor : public BranchPredictor
{
public:
	BTBPredictor(int btb_lines, int btb_assoc){
		table_entries = btb_lines;
		table_assoc = btb_assoc;
		num_sets = table_entries / table_assoc;

		correct_target_predictions = 0;
		incorrect_target_predictions = 0;

		Entries = new Entry_info [table_entries];

	}

	~BTBPredictor() {
		delete Entries;
	}

    virtual bool predict(ADDRINT ip, ADDRINT target) {
      if(find_entry(ip) != -1) return true;
      else return false;
	}

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
      int index = find_entry(ip), index_set = (ip%num_sets)*table_assoc;
      if(actual == predicted && actual ==false) correct_target_predictions++;

      if(actual){
        if(predicted){
          if(Entries[index].target_address == target){
            update_lru(ip,target,index_set,index,0);
            correct_target_predictions++;
          }
          else{
            Entries[index].target_address = target;
            update_lru(ip,target,index_set,index,0);
            incorrect_target_predictions++;
          }
        }
        else{
          update_lru(ip,target,index_set,index,1);
        }
      }
    else{
      if(predicted){
        update_lru(ip,target,index_set,index,2);
      }
    }
    updateCounters(predicted,actual);
	}


  void update_lru (ADDRINT ip, ADDRINT target,int index_set, int index, int st){
    int lru = -2;
    Entry_info *entry;
    switch (st) {
      case 0:{
        if(table_assoc == 1) break;
        lru = Entries[index].set_pos;
        for(int i=0; i<table_assoc; i++){
          entry = &Entries[index_set + i];
          if(entry->set_pos != -1 && entry->set_pos < lru) entry->set_pos++;
        }
        Entries[index].set_pos = 1;
        break;
      }
      case 1:{
        int replace_index = 0, empty = 0;
        if(table_assoc == 1){
          Entries[index_set].set(ip,target,-1);
          break;
        }
        for(int i=0; i<table_assoc; i++){
          entry = &Entries[index_set + i];
          lru = max(lru,entry->set_pos);
          if(lru == entry->set_pos) replace_index = i;
          if(entry->set_pos==-1) empty = i;
        }
        if(lru == -1) Entries[index_set+empty].set(ip,target,1);
        else if(lru == table_assoc){
          for(int i=0; i<table_assoc; i++)
            Entries[index_set + i].set_pos++;
          Entries[index_set + replace_index].set(ip,target,1);
        }
        else{
          for(int i=0; i<table_assoc; i++){
            entry = &Entries[index_set + i];
            if(entry->set_pos !=-1) entry->set_pos++;
          }
          Entries[index_set + empty].set(ip,target,1);
        }
        break;
      }
      case 2:{
        if(table_assoc == 1){
          Entries[index].reset();
          break;
        }
        lru = Entries[index].set_pos;
        Entries[index].reset();
        for(int i=0; i<table_assoc; i++){
          entry = &Entries[index_set + i];
          if(entry->set_pos != -1 && entry->set_pos > lru) entry->set_pos--;
        }
        break;
      }
    }
  }

  UINT64 getNumCorrectTargetPredictions() {
      return correct_target_predictions;
	}

  UINT64 getNumInCorrectTargetPredictions() {
		return  incorrect_target_predictions;
	}

	// UINT64 getBtbMisses() {
	// 	return  btb_misses;
	// }
	// UINT64 getset() {
	// 	return  num_sets;
	// }
  virtual string getName() {
    std::ostringstream stream;
    stream << "BTB-" << table_entries << "-" << table_assoc;
    return stream.str();
  }


  int find_entry (ADDRINT ip){
    int index_set = ip%num_sets;
    Entry_info *entry;
    for(int i=0; i<table_assoc; i++){
      entry = &Entries[index_set*table_assoc + i];
      if(entry->branch_address == ip) return index_set*table_assoc + i;
    }
    return -1;
  }

private:
	int table_entries, table_assoc;
	int num_sets;
	int correct_target_predictions, incorrect_target_predictions;
	Entry_info *Entries;
};

#endif
