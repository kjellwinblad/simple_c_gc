#include "simple_c_gc.h"
#include "stdio.h"
#include "stdlib.h"

static size_t nr_of_objects_created = 0;
static size_t nr_of_objects = 0;
static size_t peek_nr_of_objects = 0;

static void* my_malloc(size_t size){
  nr_of_objects++;
  nr_of_objects_created++;
  if(nr_of_objects > peek_nr_of_objects){
    peek_nr_of_objects = nr_of_objects;
  }
  return calloc(1, size);
}

static void my_free( void* ptr ) {
  nr_of_objects--;
  free(ptr);
}

int my_main(int argc,
            char *argv[]){
  void ** my = scgc_new(100);
  printf("my %p %p\n",my,&my);
  for(int i; i < 100000; i++){
    my[0] = scgc_new(32);
    my[1] = scgc_new(32);
    my[2] = scgc_new(32);
   ((void**)my[2])[0] = scgc_new(32);
   ((void**)my[2])[1] = scgc_new(32);
   printf("test1 %p\n",((void**)my[0])[0]);
   printf("test2 %p\n",((void**)my[1])[0]);
   printf("test3 %p\n",((void***)my[2])[0][0]);
   printf("test4 %p\n",((void***)my[2])[1][0]);
  }
  return 0;
}

int main(int argc,
         char *argv[]){
  /*Test the gc*/
  scgc_start_gced_code(my_main,argc,argv, my_malloc, my_free);
  fprintf(stderr, "Peek nr of live objects: %lu\n", peek_nr_of_objects);
  fprintf(stderr, "Nr of objects after: %lu\n", nr_of_objects);
  fprintf(stderr, "Nr of objects created: %lu\n", nr_of_objects_created);
  return 0;
}
