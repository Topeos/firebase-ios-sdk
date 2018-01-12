/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "FirebaseFirestore/FIRQuery.h"
#import "Firestore/Source/API/FIRQuery+Internal.h"
#import "Firestore/Source/Core/FSTQuery.h"
#import "Firestore/Source/Model/FSTPath.h"

#import "Firestore/Example/Tests/API/FSTAPIHelpers.h"

NS_ASSUME_NONNULL_BEGIN

@interface FIRQueryTests : XCTestCase
@end

@implementation FIRQueryTests

- (void)testEquals {
  FIRFirestore *firestore = FSTTestFirestore();
  FIRQuery *queryFoo = [FIRQuery referenceWithQuery:FSTTestQuery(@"foo") firestore:firestore];
  FIRQuery *queryFooDup = [FIRQuery referenceWithQuery:FSTTestQuery(@"foo") firestore:firestore];
  FIRQuery *queryBar = [FIRQuery referenceWithQuery:FSTTestQuery(@"bar") firestore:firestore];
  XCTAssertEqualObjects(queryFoo, queryFooDup);
  XCTAssertNotEqualObjects(queryFoo, queryBar);
  XCTAssertEqualObjects([queryFoo queryWhereField:@"f" isEqualTo:@1],
                        [queryFoo queryWhereField:@"f" isEqualTo:@1]);
  XCTAssertNotEqualObjects([queryFoo queryWhereField:@"f" isEqualTo:@1],
                           [queryFoo queryWhereField:@"f" isEqualTo:@2]);

  XCTAssertEqual([queryFoo hash], [queryFooDup hash]);
  XCTAssertNotEqual([queryFoo hash], [queryBar hash]);
  XCTAssertEqual([[queryFoo queryWhereField:@"f" isEqualTo:@1] hash],
                 [[queryFoo queryWhereField:@"f" isEqualTo:@1] hash]);
  XCTAssertNotEqual([[queryFoo queryWhereField:@"f" isEqualTo:@1] hash],
                    [[queryFoo queryWhereField:@"f" isEqualTo:@2] hash]);
}

- (void)testFilteringWithPredicate {
  FIRFirestore *firestore = FSTTestFirestore();
  FIRQuery *query = [FIRQuery referenceWithQuery:FSTTestQuery(@"foo") firestore:firestore];
  FIRQuery *query1 = [query queryWhereField:@"f" isLessThanOrEqualTo:@1];
  FIRQuery *query2 = [query queryFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"f<=1"]];
  FIRQuery *query3 =
      [[query queryWhereField:@"f1" isLessThan:@2] queryWhereField:@"f2" isEqualTo:@3];
  FIRQuery *query4 =
      [query queryFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"f1<2 && f2==3"]];
  FIRQuery *query5 =
      [[[[[query queryWhereField:@"f1" isLessThan:@2] queryWhereField:@"f2" isEqualTo:@3]
              queryWhereField:@"f1"
          isLessThanOrEqualTo:@"four"] queryWhereField:@"f1"
                                isGreaterThanOrEqualTo:@"five"] queryWhereField:@"f1"
                                                                  isGreaterThan:@6];
  FIRQuery *query6 = [query
      queryFilteredUsingPredicate:
          [NSPredicate predicateWithFormat:@"f1<2 && f2==3 && f1<='four' && f1>='five' && f1>6"]];
  FIRQuery *query7 = [query
      queryFilteredUsingPredicate:
          [NSPredicate predicateWithFormat:@"2>f1 && 3==f2 && 'four'>=f1 && 'five'<=f1 && 6<f1"]];
  XCTAssertEqualObjects(query1, query2);
  XCTAssertNotEqualObjects(query2, query3);
  XCTAssertEqualObjects(query3, query4);
  XCTAssertNotEqualObjects(query4, query5);
  XCTAssertEqualObjects(query5, query6);
  XCTAssertEqualObjects(query6, query7);
}

@end

NS_ASSUME_NONNULL_END