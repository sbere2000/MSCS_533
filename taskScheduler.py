# Bereket Gebremariam
# POC for task scheduler
class TaskScheduler:
    """
    A Task Scheduler that uses a Hash Table (Python dict) for O(1) metadata access
    and a Priority Queue (Heap) for O(log n) prioritization.
    """
    def __init__(self):
        # The Hash Table: Maps task_id (Key) to metadata (Value) [cite: 30]
        # Value structure: {'deadline': int, 'urgency': int, 'description': str}
        self.task_metadata = {}
        # NOTE: For the final implementation, you would also initialize the Min-Heap here.
        # self.min_heap = []

    def add_task_metadata(self, task_id, deadline, urgency, description):
        """
        Implements the O(1) Hash Table Insert/Add operation[cite: 30, 38].
        """
        if task_id in self.task_metadata:
            # Simple error handling for duplicate IDs
            return f"Error: Task ID '{task_id}' already exists."
        
        # Store all task metadata [cite: 33]
        self.task_metadata[task_id] = {
            'deadline': deadline,
            'urgency': urgency,  # Note: urgency is referred to as 'bid' in the paper [cite: 34]
            'description': description
        }
        return f"Metadata added for Task ID: {task_id}"

    def find_task_metadata(self, task_id):
        """
        Implements the O(1) Hash Table Lookup operation (find_task)[cite: 25, 30, 40].
        """
        if task_id in self.task_metadata:
            # Provides instant access to task details [cite: 33]
            return self.task_metadata[task_id]
        else:
            return f"Error: Task ID '{task_id}' not found."

    def complete_task_metadata(self, task_id):
        """
        Implements the O(1) Hash Table Delete operation (complete_task)[cite: 30, 41].
        """
        if task_id in self.task_metadata:
            del self.task_metadata[task_id]
            return f"Metadata deleted for Task ID: {task_id}"
        else:
            return f"Error: Task ID '{task_id}' not found."
    
################################# TEST ##############################
# Create the scheduler instance
scheduler_poc = TaskScheduler()

print("--- DEMO 1: Task Insertion (add_task) ---")
# 1. Basic Insert
print(scheduler_poc.add_task_metadata("T101", 10, 50, "Design Interface"))
print(scheduler_poc.add_task_metadata("T102", 5, 100, "Fix critical bug"))
print(scheduler_poc.add_task_metadata("T103", 20, 25, "Write documentation"))
print(f"Current tasks in Hash Table: {list(scheduler_poc.task_metadata.keys())}\n")

print("--- DEMO 2: Task Lookup (find_task) ---")
# 2. Basic Lookup (O(1) access) [cite: 25]
task_info = scheduler_poc.find_task_metadata("T102")
print(f"Details for T102: {task_info}")
# 3. Edge Case: Not Found Lookup
print(f"Details for T999: {scheduler_poc.find_task_metadata('T999')}\n")

print("--- DEMO 3: Task Deletion (complete_task) ---")
# 4. Basic Delete (O(1) removal) [cite: 30]
print(scheduler_poc.complete_task_metadata("T101"))
print(f"Current tasks in Hash Table after T101 deletion: {list(scheduler_poc.task_metadata.keys())}")
# 5. Edge Case: Double Deletion (should report error)
print(scheduler_poc.complete_task_metadata("T101"))