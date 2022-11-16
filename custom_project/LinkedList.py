class Node:
	def __init__(self, data =None, next = None):
		self.data = data
		self.next = next
class LinkedList:
	def __init__(self):
		self.head = None

	def insert_at_begining(self,data):
		node = Node(data,self.head)
		self.head = node
	def print(self):
		if self.head is None:
			print('LinkedList is empty')
			return
		itr = self.head
		llstr = ''
		while itr:
			llstr += str(itr.data) + '-->'
			itr = itr.next
		print(llstr)
	def insert_at_end(self,data):
		if self.head is None:
			self.head = Node(data,None)
			return

		itr = self.head
		while itr.next:
			itr = itr.next
		itr.next = Node(data,None)

		
	def insert_values(self,data_list):
		self.head = None
		for data in data_list:
			self.insert_at_end(data)
	def get_length(self):
		count = 0 
		itr = self.head
		while itr:
			count +=1
			itr = itr.next
		return count
	def remove_at(self, index):
		if index < 0 or index>= self.get_length():
			raise Exception('Invalid index')
		if index ==0:
			self.head = self.head.next
			return
		count = 0 
		itr = self.head
		while itr:
			if count == index -1 :
				itr.next = itr.next.next
				break
			itr = itr.next
			count += 1
	def insert_at(self,index,data):
		if index < 0 or index >= self.get_length():
			raise Exception('Invalid index')
		if index == 0:
			self.insert_at_begining(data)
			return
		count = 0
		itr = self.head
		while itr:
			if count == index -1:
				node = Node(data,itr.next)
				itr.next = node
				break
			itr = itr.next
			count +=1
	def reverse(self):
		itr = self.head
		prev = None
		while itr :
			temp = itr.next
			itr.next = prev
			prev = itr  
			itr = temp
		self.head = prev

	#Merge sort in linked list
	def get_middle(self,head):
		if head is None:
			return head
		slow = head
		fast = head
		while fast.next and fast.next.next:
			slow = slow.next
			fast = fast.next.next
		return slow
	def sortedMerge(self,ll1,ll2):
		if ll1 is None:
			return ll2
		if ll2 is None:
			return ll1
		if ll1.data < ll2.data:
			temp = ll1
			temp.next = self.sortedMerge(ll1.next,ll2)
		else:
			temp = ll2
			temp.next = self.sortedMerge(ll1,ll2.next)
		return temp

	def mergeSort(self,head):
		if head is None or head.next is None:
			return head
		middle = self.get_middle(head)
		head2 = middle.next

		middle.next = None
		left = self.mergeSort(head)
		right = self.mergeSort(head2)
		final_list = self.sortedMerge(left,right)
		return final_list
def reverse_recursive(head):
	if head is None:
		return None
	if head.next is None:
		return head
	second = head.next
	head.next = None
	reverse = reverse_recursive(second)
	second.next = head
	return reverse
def merge_sorted_linkedlist():
	pass
if __name__ == '__main__':
	ll = LinkedList()
	ll.insert_at_begining(5)
	ll.insert_at_begining(82)
	ll.insert_at_end(19)
	ll.insert_at_end(21)
	ll.insert_at_end(15)
	ll.head = ll.mergeSort(ll.head)
	ll.head = reverse_recursive(ll.head)
	ll.print()
	

	ll5 = LinkedList()
	ll4 = LinkedList()
	mergedlist = LinkedList()
	ll4.insert_at_end(5)
	ll4.insert_at_end(10)
	ll4.insert_at_end(15)

	ll5.insert_at_end(0)
	ll5.insert_at_end(2)
	ll5.insert_at_end(18)
    
	mergedlist.head = mergedlist.sortedMerge(ll4.head,ll5.head)
	mergedlist.print()


	ll2 = LinkedList()
	ll2.insert_values(['Hello','World','Chemical','Math'])
	ll2.remove_at(1)
	ll2.insert_at(2,'Yeu')
	ll2.reverse()
	ll2.print()

	ll3 = LinkedList()
	ll3.insert_values([1,2,3,4,5,6])



