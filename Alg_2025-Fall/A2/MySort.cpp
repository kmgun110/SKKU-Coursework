#include <cstdio>
#include <chrono>
#include <cmath>


/////////////////////////////////////////////////////////////////////////
//////////////// YOUR PLAYGROUND FROM HERE ////////////////
////////////////////////////////////////////////////////////////////////

inline void swap(int &a, int &b)
{
	int t = a;
	a = b;
	b = t;
}

inline int find_depth(int n)	// find depth for threshold depth -> IntroSort
{
	int k = 0;
	while (n > 1)
	{
		n >>= 1;
		++k;
	}
	return k;	// k = lg(n)
}

void insertion_sort(int *d, int _first, int _last)
{
	for (int i = _first + 1; i <= _last; ++i)
	{
		int tmp = d[i];
		int j = i;
		while (j > _first && d[j - 1] > tmp)
		{
			d[j] = d[j - 1];
			--j;
		}
		d[j] = tmp;
	}
}

int median_of_three(int *d, int _first, int _last)	// find pivot, split by pivot
{
	int mid = _first + (_last - _first) / 2;

	if (d[mid] < d[_first]) swap(d[mid], d[_first]);
	if (d[_last] < d[mid]) swap(d[_last], d[mid]);
	if (d[mid] < d[_first]) swap(d[mid], d[_first]);

	//int pivot_idx = mid;
	int pivot_val = d[mid];
	swap(d[mid], d[_last]);

	int i = _first;
	for (int j = _first; j < _last; ++j)
	{
		if (d[j] < pivot_val)
		{
			swap(d[j], d[i]);
			++i;
		}
	}

	swap(d[_last], d[i]);
	return i;  // i: pivot index after partition
}

void heapify(int *d, int _first, int size, int idx)   // construct max heap
{
	while (true)
	{
		int chi_1 = 2 * idx + 1;
		int chi_2 = 2 * idx + 2;
		int par = idx;
		
		if (chi_1 < size && d[_first + chi_1] > d[_first + par])
			par = chi_1;
		if (chi_2 < size && d[_first + chi_2] > d[_first + par])
			par = chi_2;
		if (par == idx) 
			break;

		swap(d[_first + idx], d[_first + par]);
		idx = par;
	}
}

void heap_sort(int *d, int _first, int _last)
{
	int len = _last - _first + 1;
	if (len <= 1)
		return;

	for (int i = len / 2 - 1; i >= 0; --i)
		heapify(d, _first, len, i);

	for (int i = len - 1; i > 0; --i)
	{
		swap(d[_first], d[_first + i]);
		heapify(d, _first, i, 0);
	}
}

void intro_sort(int *d, int _first, int _last, int depth)
{
	const int threshold = 100;

	while (_last - _first + 1 > threshold)
	{
		if (depth == 0)	// bad pivot selection, bad partition
		{
			heap_sort(d, _first, _last);
			return;
		}
		--depth;

		int idx = median_of_three(d, _first, _last);
		
		if (idx - 1 - _first < _last - (idx + 1))
		{
			if (_first < idx - 1)
				intro_sort(d, _first, idx - 1, depth);
			_first = idx + 1;
		}
		else 
		{
			if (idx + 1 < _last)
				intro_sort(d, idx + 1, _last, depth);
			_last = idx - 1;
		}
	}
}

inline int bucket_index(int x, int min, long long width, int B)	// find bucket index
{
	long long idx = ((long long)x - (long long)min) / width;
	if (idx < 0) idx = 0;
	if (idx >= B) idx = B - 1;
	return (int)idx; 
}

void bucket_intro_sort(int n, int *d, int min, int max)
{
	long long range = (long long)max - (long long)min + 1;

	int B = n / 10000;	// 10^4 data per bucket
	if (B < 10) B = 10; // minimum number of buckets
	if (B > 5000) B = 5000; //maximum number of buckets

	long long width = (range + B - 1) / B;
	if (width <= 0) width = 1;

	int *count = new int[B];	// number of data in bucket
	int *start = new int[B];	// start index of present bucket in the data d
	int *end = new int[B];	// end index of present bucket in the data d
	int *next = new int[B];	// blank index in present bucket

	for (int i = 0; i < B; ++i)
		count [i] = 0;

	for (int i = 0; i < n; ++i)
	{
		int b = bucket_index(d[i], min, width, B);
		++count[b];
	}

	int pos = 0;
	for (int b = 0; b < B; ++b)
	{
		start[b] = pos;
		pos += count[b];
		end[b] = pos;
		next[b] = start[b];
	}

	for (int i = 0; i < n; ++i)
	{
		while (true)
		{
			int b = bucket_index(d[i], min, width, B);

			if (i >= start[b] && i < next[b])
				break;

			int dest = next[b]++;
			swap(d[i], d[dest]);
		}
	}

	for (int b = 0; b < B; ++b)
	{
		int len = end[b] - start[b];
		if (len <= 1) continue;

		int _first = start[b];
		int _last = end[b] - 1;

		if (len <= 30)
		{
			insertion_sort(d, _first, _last);
		}
		else
		{
			int depth = 2 * find_depth(len);
			intro_sort(d, _first, _last, depth);
			insertion_sort(d, _first, _last);
		}
	}

	delete [] count;
	delete [] start;
	delete [] end;
	delete [] next;
}

void MyVeryFastSort(int n, int *d)
{
	if (n <= 1) return;	
	if (n <= 30)		// insertion sort for small data size
	{
		insertion_sort(d, 0, n - 1);
		return;
	}

	int min = d[0];
	int max = d[0];

	for (int i = 1; i < n; ++i)
	{
		if (d[i] < min)
			min = d[i];
		if (d[i] > max)
			max = d[i];	
	}

	long long range = (long long)max - (long long)min + 1;

	if (range == 1) return;

	if (n >= 100000)
		bucket_intro_sort(n, d, min, max);
	else
	{
		int depth = 2 * find_depth(n);
		intro_sort(d, 0, n - 1, depth);
		insertion_sort(d, 0, n - 1);
	}
}



/////////////////////////////////////////////////////////////////////////
//////////////// YOUR PLAYGROUND ENDS HERE ////////////////
////////////////////////////////////////////////////////////////////////

// Utilized to check the correctness
bool Validate(int n, int *d)
{
	for(int i=1;i<n;i++)
	{
		if( d[i-1] > d[i] )
		{
			return false;
		}
	}	
	return true;
}

int main(int argc, char **argv)
{
	if( argc != 3 )
	{
		fprintf( stderr , "USAGE:  EXECUTABLE   INPUT_FILE_NAME   OUTPUT_FILE_NAME\n");
		return 1;
	}

	// Get input from a binary file whose name is provided from the command line
	int n, *d;
	FILE *input = fopen( argv[1] , "rb" );
	int e = fread( &n , sizeof(int) , 1 , input );
	d = new int [ n ];
	e = fread( d , sizeof(int) , n , input );
	fclose(input);

	std::chrono::time_point<std::chrono::system_clock> start = std::chrono::system_clock::now();

	// Call your sorting algorithm
	MyVeryFastSort( n , d );

	std::chrono::time_point<std::chrono::system_clock> end = std::chrono::system_clock::now();
	std::chrono::milliseconds elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
	double res_time = elapsed_time.count();

	bool res_validate = Validate( n , d );

	// Write the results (corretness and time)
	FILE *output = fopen( argv[2] , "w" );
	if( res_validate ) { fprintf( output , "OKAY\n" ); printf("OKAY\n"); }
	else { fprintf( output , "WRONG\n" ); printf("WRONG\n");  }
	fprintf( output , "%d\n" , (int)res_time );
	printf( "%d\n" , (int)res_time );
	fclose(output);

	delete [] d;

	return 1;
}