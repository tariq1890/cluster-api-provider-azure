# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build the manager binary
FROM golang:1.11.5 as builder

# Copy in the go src
WORKDIR /go/src/sigs.k8s.io/cluster-api-provider-azure
COPY pkg/    pkg/
COPY cmd/    cmd/
COPY vendor/ vendor/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o manager sigs.k8s.io/cluster-api-provider-azure/cmd/manager

# Copy the controller-manager into a thin image
FROM alpine:3.9
WORKDIR /root/
COPY --from=builder /go/src/sigs.k8s.io/cluster-api-provider-azure/manager .
COPY --from=builder /go/src/sigs.k8s.io/cluster-api-provider-azure/pkg/cloud/azure/services/resources/template/deployment-template.json .
ENTRYPOINT ["./manager"]
