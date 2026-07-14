/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/collab_endpoint.dart' as _i2;
import '../endpoints/consumable_endpoint.dart' as _i3;
import '../endpoints/equipment_endpoint.dart' as _i4;
import '../endpoints/health_endpoint.dart' as _i5;
import '../endpoints/intake_endpoint.dart' as _i6;
import '../endpoints/meeting_endpoint.dart' as _i7;
import '../endpoints/onboarding_endpoint.dart' as _i8;
import '../endpoints/org_endpoint.dart' as _i9;
import '../endpoints/partnership_endpoint.dart' as _i10;
import '../endpoints/project_endpoint.dart' as _i11;
import '../endpoints/realtime_endpoint.dart' as _i12;
import '../endpoints/sync_endpoint.dart' as _i13;
import '../endpoints/task_endpoint.dart' as _i14;
import '../endpoints/trash_endpoint.dart' as _i15;
import 'package:makerflow_server/src/generated/item_comment.dart' as _i16;
import 'package:makerflow_server/src/generated/consumable.dart' as _i17;
import 'package:makerflow_server/src/generated/enums/equipment_status.dart'
    as _i18;
import 'package:makerflow_server/src/generated/equipment_asset.dart' as _i19;
import 'package:makerflow_server/src/generated/intake_request.dart' as _i20;
import 'package:makerflow_server/src/generated/meeting_agenda.dart' as _i21;
import 'package:makerflow_server/src/generated/meeting_item.dart' as _i22;
import 'package:makerflow_server/src/generated/onboarding_template.dart'
    as _i23;
import 'package:makerflow_server/src/generated/enums/onboarding_state.dart'
    as _i24;
import 'package:makerflow_server/src/generated/enums/membership_role.dart'
    as _i25;
import 'package:makerflow_server/src/generated/enums/partnership_stage.dart'
    as _i26;
import 'package:makerflow_server/src/generated/partnership.dart' as _i27;
import 'package:makerflow_server/src/generated/project.dart' as _i28;
import 'package:makerflow_server/src/generated/enums/task_status.dart' as _i29;
import 'package:makerflow_server/src/generated/task.dart' as _i30;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i31;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'collab': _i2.CollabEndpoint()
        ..initialize(
          server,
          'collab',
          null,
        ),
      'consumable': _i3.ConsumableEndpoint()
        ..initialize(
          server,
          'consumable',
          null,
        ),
      'equipment': _i4.EquipmentEndpoint()
        ..initialize(
          server,
          'equipment',
          null,
        ),
      'health': _i5.HealthEndpoint()
        ..initialize(
          server,
          'health',
          null,
        ),
      'intake': _i6.IntakeEndpoint()
        ..initialize(
          server,
          'intake',
          null,
        ),
      'meeting': _i7.MeetingEndpoint()
        ..initialize(
          server,
          'meeting',
          null,
        ),
      'onboarding': _i8.OnboardingEndpoint()
        ..initialize(
          server,
          'onboarding',
          null,
        ),
      'org': _i9.OrgEndpoint()
        ..initialize(
          server,
          'org',
          null,
        ),
      'partnership': _i10.PartnershipEndpoint()
        ..initialize(
          server,
          'partnership',
          null,
        ),
      'project': _i11.ProjectEndpoint()
        ..initialize(
          server,
          'project',
          null,
        ),
      'realtime': _i12.RealtimeEndpoint()
        ..initialize(
          server,
          'realtime',
          null,
        ),
      'sync': _i13.SyncEndpoint()
        ..initialize(
          server,
          'sync',
          null,
        ),
      'task': _i14.TaskEndpoint()
        ..initialize(
          server,
          'task',
          null,
        ),
      'trash': _i15.TrashEndpoint()
        ..initialize(
          server,
          'trash',
          null,
        ),
    };
    connectors['collab'] = _i1.EndpointConnector(
      name: 'collab',
      endpoint: endpoints['collab']!,
      methodConnectors: {
        'comments': _i1.MethodConnector(
          name: 'comments',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'entityType': _i1.ParameterDescription(
              name: 'entityType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'entityId': _i1.ParameterDescription(
              name: 'entityId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['collab'] as _i2.CollabEndpoint).comments(
                session,
                params['organizationId'],
                params['entityType'],
                params['entityId'],
              ),
        ),
        'addComment': _i1.MethodConnector(
          name: 'addComment',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i16.ItemComment>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['collab'] as _i2.CollabEndpoint).addComment(
                session,
                params['draft'],
              ),
        ),
        'watch': _i1.MethodConnector(
          name: 'watch',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'entityType': _i1.ParameterDescription(
              name: 'entityType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'entityId': _i1.ParameterDescription(
              name: 'entityId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'watching': _i1.ParameterDescription(
              name: 'watching',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['collab'] as _i2.CollabEndpoint).watch(
                session,
                params['organizationId'],
                params['entityType'],
                params['entityId'],
                params['watching'],
              ),
        ),
        'activityStream': _i1.MethodStreamConnector(
          name: 'activityStream',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['collab'] as _i2.CollabEndpoint).activityStream(
                session,
                params['organizationId'],
              ),
        ),
      },
    );
    connectors['consumable'] = _i1.EndpointConnector(
      name: 'consumable',
      endpoint: endpoints['consumable']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['consumable'] as _i3.ConsumableEndpoint).list(
                    session,
                    params['organizationId'],
                  ),
        ),
        'save': _i1.MethodConnector(
          name: 'save',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i17.Consumable>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['consumable'] as _i3.ConsumableEndpoint).save(
                    session,
                    params['draft'],
                  ),
        ),
        'softDelete': _i1.MethodConnector(
          name: 'softDelete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['consumable'] as _i3.ConsumableEndpoint)
                  .softDelete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['equipment'] = _i1.EndpointConnector(
      name: 'equipment',
      endpoint: endpoints['equipment']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i18.EquipmentStatus?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['equipment'] as _i4.EquipmentEndpoint).list(
                session,
                params['organizationId'],
                status: params['status'],
              ),
        ),
        'save': _i1.MethodConnector(
          name: 'save',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i19.EquipmentAsset>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['equipment'] as _i4.EquipmentEndpoint).save(
                session,
                params['draft'],
              ),
        ),
        'softDelete': _i1.MethodConnector(
          name: 'softDelete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['equipment'] as _i4.EquipmentEndpoint).softDelete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['health'] = _i1.EndpointConnector(
      name: 'health',
      endpoint: endpoints['health']!,
      methodConnectors: {
        'ready': _i1.MethodConnector(
          name: 'ready',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['health'] as _i5.HealthEndpoint).ready(session),
        ),
      },
    );
    connectors['intake'] = _i1.EndpointConnector(
      name: 'intake',
      endpoint: endpoints['intake']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['intake'] as _i6.IntakeEndpoint).list(
                session,
                params['organizationId'],
              ),
        ),
        'save': _i1.MethodConnector(
          name: 'save',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i20.IntakeRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['intake'] as _i6.IntakeEndpoint).save(
                session,
                params['draft'],
              ),
        ),
        'convertToProject': _i1.MethodConnector(
          name: 'convertToProject',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'requestId': _i1.ParameterDescription(
              name: 'requestId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['intake'] as _i6.IntakeEndpoint).convertToProject(
                    session,
                    params['organizationId'],
                    params['requestId'],
                  ),
        ),
      },
    );
    connectors['meeting'] = _i1.EndpointConnector(
      name: 'meeting',
      endpoint: endpoints['meeting']!,
      methodConnectors: {
        'agendas': _i1.MethodConnector(
          name: 'agendas',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['meeting'] as _i7.MeetingEndpoint).agendas(
                session,
                params['organizationId'],
              ),
        ),
        'items': _i1.MethodConnector(
          name: 'items',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'agendaId': _i1.ParameterDescription(
              name: 'agendaId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['meeting'] as _i7.MeetingEndpoint).items(
                session,
                params['organizationId'],
                params['agendaId'],
              ),
        ),
        'saveAgenda': _i1.MethodConnector(
          name: 'saveAgenda',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i21.MeetingAgenda>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['meeting'] as _i7.MeetingEndpoint).saveAgenda(
                    session,
                    params['draft'],
                  ),
        ),
        'saveItem': _i1.MethodConnector(
          name: 'saveItem',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i22.MeetingItem>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['meeting'] as _i7.MeetingEndpoint).saveItem(
                session,
                params['draft'],
              ),
        ),
        'convertItemToTask': _i1.MethodConnector(
          name: 'convertItemToTask',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'itemId': _i1.ParameterDescription(
              name: 'itemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['meeting'] as _i7.MeetingEndpoint)
                  .convertItemToTask(
                    session,
                    params['organizationId'],
                    params['itemId'],
                  ),
        ),
      },
    );
    connectors['onboarding'] = _i1.EndpointConnector(
      name: 'onboarding',
      endpoint: endpoints['onboarding']!,
      methodConnectors: {
        'templates': _i1.MethodConnector(
          name: 'templates',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['onboarding'] as _i8.OnboardingEndpoint).templates(
                    session,
                    params['organizationId'],
                  ),
        ),
        'saveTemplate': _i1.MethodConnector(
          name: 'saveTemplate',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i23.OnboardingTemplate>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['onboarding'] as _i8.OnboardingEndpoint)
                  .saveTemplate(
                    session,
                    params['draft'],
                  ),
        ),
        'assign': _i1.MethodConnector(
          name: 'assign',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'templateId': _i1.ParameterDescription(
              name: 'templateId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'assigneeUserInfoId': _i1.ParameterDescription(
              name: 'assigneeUserInfoId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'dueAt': _i1.ParameterDescription(
              name: 'dueAt',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['onboarding'] as _i8.OnboardingEndpoint).assign(
                    session,
                    params['organizationId'],
                    params['templateId'],
                    params['assigneeUserInfoId'],
                    params['dueAt'],
                  ),
        ),
        'setState': _i1.MethodConnector(
          name: 'setState',
          params: {
            'assignmentId': _i1.ParameterDescription(
              name: 'assignmentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'state': _i1.ParameterDescription(
              name: 'state',
              type: _i1.getType<_i24.OnboardingState>(),
              nullable: false,
            ),
            'progressJson': _i1.ParameterDescription(
              name: 'progressJson',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['onboarding'] as _i8.OnboardingEndpoint).setState(
                    session,
                    params['assignmentId'],
                    params['state'],
                    params['progressJson'],
                  ),
        ),
      },
    );
    connectors['org'] = _i1.EndpointConnector(
      name: 'org',
      endpoint: endpoints['org']!,
      methodConnectors: {
        'listMine': _i1.MethodConnector(
          name: 'listMine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['org'] as _i9.OrgEndpoint).listMine(session),
        ),
        'members': _i1.MethodConnector(
          name: 'members',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['org'] as _i9.OrgEndpoint).members(
                session,
                params['organizationId'],
              ),
        ),
        'setRole': _i1.MethodConnector(
          name: 'setRole',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'targetUserInfoId': _i1.ParameterDescription(
              name: 'targetUserInfoId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i25.MembershipRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['org'] as _i9.OrgEndpoint).setRole(
                session,
                params['organizationId'],
                params['targetUserInfoId'],
                params['role'],
              ),
        ),
        'removeMember': _i1.MethodConnector(
          name: 'removeMember',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'targetUserInfoId': _i1.ParameterDescription(
              name: 'targetUserInfoId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['org'] as _i9.OrgEndpoint).removeMember(
                session,
                params['organizationId'],
                params['targetUserInfoId'],
              ),
        ),
      },
    );
    connectors['partnership'] = _i1.EndpointConnector(
      name: 'partnership',
      endpoint: endpoints['partnership']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'stage': _i1.ParameterDescription(
              name: 'stage',
              type: _i1.getType<_i26.PartnershipStage?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['partnership'] as _i10.PartnershipEndpoint).list(
                    session,
                    params['organizationId'],
                    stage: params['stage'],
                  ),
        ),
        'save': _i1.MethodConnector(
          name: 'save',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i27.Partnership>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['partnership'] as _i10.PartnershipEndpoint).save(
                    session,
                    params['draft'],
                  ),
        ),
        'softDelete': _i1.MethodConnector(
          name: 'softDelete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['partnership'] as _i10.PartnershipEndpoint)
                  .softDelete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['project'] = _i1.EndpointConnector(
      name: 'project',
      endpoint: endpoints['project']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i11.ProjectEndpoint).list(
                session,
                params['organizationId'],
              ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i28.Project>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i11.ProjectEndpoint).create(
                session,
                params['draft'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'incoming': _i1.ParameterDescription(
              name: 'incoming',
              type: _i1.getType<_i28.Project>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i11.ProjectEndpoint).update(
                session,
                params['incoming'],
              ),
        ),
        'softDelete': _i1.MethodConnector(
          name: 'softDelete',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i11.ProjectEndpoint).softDelete(
                    session,
                    params['projectId'],
                  ),
        ),
      },
    );
    connectors['realtime'] = _i1.EndpointConnector(
      name: 'realtime',
      endpoint: endpoints['realtime']!,
      methodConnectors: {
        'subscribe': _i1.MethodStreamConnector(
          name: 'subscribe',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['realtime'] as _i12.RealtimeEndpoint).subscribe(
                session,
                params['organizationId'],
              ),
        ),
      },
    );
    connectors['sync'] = _i1.EndpointConnector(
      name: 'sync',
      endpoint: endpoints['sync']!,
      methodConnectors: {
        'pullTasks': _i1.MethodConnector(
          name: 'pullTasks',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'cursor': _i1.ParameterDescription(
              name: 'cursor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sync'] as _i13.SyncEndpoint).pullTasks(
                session,
                params['organizationId'],
                params['cursor'],
                limit: params['limit'],
              ),
        ),
        'ackCursor': _i1.MethodConnector(
          name: 'ackCursor',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'cursor': _i1.ParameterDescription(
              name: 'cursor',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sync'] as _i13.SyncEndpoint).ackCursor(
                session,
                params['organizationId'],
                params['deviceId'],
                params['cursor'],
              ),
        ),
      },
    );
    connectors['task'] = _i1.EndpointConnector(
      name: 'task',
      endpoint: endpoints['task']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i29.TaskStatus?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i14.TaskEndpoint).list(
                session,
                params['organizationId'],
                projectId: params['projectId'],
                status: params['status'],
              ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'draft': _i1.ParameterDescription(
              name: 'draft',
              type: _i1.getType<_i30.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i14.TaskEndpoint).create(
                session,
                params['draft'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'incoming': _i1.ParameterDescription(
              name: 'incoming',
              type: _i1.getType<_i30.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i14.TaskEndpoint).update(
                session,
                params['incoming'],
              ),
        ),
        'move': _i1.MethodConnector(
          name: 'move',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'toStatus': _i1.ParameterDescription(
              name: 'toStatus',
              type: _i1.getType<_i29.TaskStatus>(),
              nullable: false,
            ),
            'toSortOrder': _i1.ParameterDescription(
              name: 'toSortOrder',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i14.TaskEndpoint).move(
                session,
                params['taskId'],
                params['toStatus'],
                params['toSortOrder'],
              ),
        ),
        'softDelete': _i1.MethodConnector(
          name: 'softDelete',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i14.TaskEndpoint).softDelete(
                session,
                params['taskId'],
              ),
        ),
      },
    );
    connectors['trash'] = _i1.EndpointConnector(
      name: 'trash',
      endpoint: endpoints['trash']!,
      methodConnectors: {
        'deletedTasks': _i1.MethodConnector(
          name: 'deletedTasks',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['trash'] as _i15.TrashEndpoint).deletedTasks(
                    session,
                    params['organizationId'],
                  ),
        ),
        'restoreTask': _i1.MethodConnector(
          name: 'restoreTask',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trash'] as _i15.TrashEndpoint).restoreTask(
                session,
                params['id'],
              ),
        ),
        'purgeTask': _i1.MethodConnector(
          name: 'purgeTask',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trash'] as _i15.TrashEndpoint).purgeTask(
                session,
                params['id'],
              ),
        ),
      },
    );
    modules['serverpod_auth'] = _i31.Endpoints()..initializeEndpoints(server);
  }
}
