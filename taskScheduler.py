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